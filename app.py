import dash
from dash import dcc, html, Input, Output, State, dash_table
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import dash_leaflet as dl
import requests
import math
import io
from matlab_bridge import matlab_instance

# Added suppress_callback_exceptions=True to allow dynamic graph clicking
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.LUMEN, dbc.icons.BOOTSTRAP], suppress_callback_exceptions=True)

# --- HELPER FUNCTION ---
def get_radius_coords(center_lat, center_lon, radius_km, num_points=64):
    R = 6371.0 
    lats, lons = [], []
    for i in range(num_points):
        angle = math.radians(float(i) / num_points * 360.0)
        dx = radius_km * math.cos(angle)
        dy = radius_km * math.sin(angle)
        d_lat = dy / R
        d_lon = dx / (R * math.cos(math.radians(center_lat)))
        lats.append(center_lat + math.degrees(d_lat))
        lons.append(center_lon + math.degrees(d_lon))
    lats.append(lats[0]) 
    lons.append(lons[0])
    return lats, lons


# --- LAYOUT ---
app.layout = dbc.Container([
    # Hidden Store to hold data for the Pop-out Modal
    dcc.Store(id='trend-data-store'),
    
    # The Pop-out Modal (Hidden until a bar is clicked)
    dbc.Modal([
        dbc.ModalHeader(dbc.ModalTitle(id="drilldown-title", className="fw-bold")),
        dbc.ModalBody(id="drilldown-body"),
    ], id="drilldown-modal", size="lg", is_open=False, centered=True),

    dbc.Row([
        dbc.Col(html.H2(
            [html.I(className="bi bi-globe-americas text-success me-2"), "Global Green Hydrogen Insights"], 
            className="fw-bold my-4 text-dark"
        ), width=12)
    ]),
    
    dbc.Row([
        # LEFT SIDEBAR
        dbc.Col([
            dbc.Card([
                dbc.CardHeader(html.H5("Scenario Parameters", className="m-0 fw-bold")),
                dbc.CardBody([
                    html.Label("Click Map to Select Location:", className="fw-semibold text-muted small mb-2"),
                    html.Div([
                        dl.Map([
                            dl.TileLayer(),
                            dl.LayerGroup(id="layer")
                        ], id="map", center=[-25.27, 133.77], zoom=3, style={'height': '200px', 'borderRadius': '8px'}),
                    ], className="mb-3 shadow-sm"),
                    
                    html.Label("Target Coordinates (Lat, Lon)", className="fw-semibold text-muted small"),
                    dcc.Input(id='location-input', type='text', placeholder='e.g., -33.03, 137.56', value='-33.03, 137.56', className="form-control mb-3 shadow-sm"),
                    
                    html.Label("Analysis Year", className="fw-semibold text-muted small"),
                    dcc.Input(id='year-input', type='number', value=2020, min=1940, max=2024, step=1, className="form-control mb-4 shadow-sm"),
                    
                    html.Hr(),
                    html.H6("Simulation Constraints", className="fw-bold text-muted mb-3"),
                    
                    html.Label("REM Range", className="fw-semibold text-muted small"),
                    dcc.RangeSlider(id='rem-slider', min=0, max=10, step=0.25, value=[0, 5], marks={0:'0x', 5:'5x', 10:'10x'}, className="mb-4"),
                    
                    html.Label("Storage Hours Range", className="fw-semibold text-muted small"),
                    dcc.RangeSlider(id='storage-slider', min=1, max=50, step=1, value=[1, 25], marks={1:'1h', 25:'25h', 50:'50h'}, className="mb-4"),
                    
                    html.Label("Solar Share Filter (%)", className="fw-semibold text-muted small"),
                    dcc.RangeSlider(id='pv-slider', min=0, max=100, step=5, value=[20, 60], marks={0:'0%', 50:'50%', 100:'100%'}, className="mb-4"),

                    html.Label("Overcapacity (OcM) Filter", className="fw-semibold text-muted small"),
                    dcc.RangeSlider(id='ocm-slider', min=0.5, max=5, step=0.5, value=[0.5, 3], marks={0.5:'0.5x', 3:'3x', 5:'5x'}, className="mb-4"),
                    
                    dbc.Button([html.I(className="bi bi-play-fill me-2"), "Run Simulation"], id="run-button", color="success", className="w-100 fw-bold shadow-sm"),
                    
                    html.Div([
                        dbc.Accordion([
                            dbc.AccordionItem([
                                dbc.Row([
                                    dbc.Col([
                                        html.H6("Solar & Wind Physics", className="fw-bold text-dark mb-2", style={"fontSize": "0.85rem"}),
                                        html.P("Panel Area: 2.52 m²", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Solar Efficiency: 19%", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("PV Capacity Factor: 22.23%", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Wind Hub Height: 100m", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Wind Rotor Radius: 82.5m", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Wind Rated Power: 5.2 MW", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                    ], width=6),
                                    dbc.Col([
                                        html.H6("Plant & Production Targets", className="fw-bold text-dark mb-2", style={"fontSize": "0.85rem"}),
                                        html.P("Steel Target: 1,000,000 t/yr", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Electrolyser: 49.9 kWh/kg", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("EAF Cons: 753 kWh/t", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("System Degradation: 0.3%/yr", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                        html.P("Plant Age (Initial): 0 Yrs", className="mb-1 text-muted", style={"fontSize": "0.75rem"}),
                                    ], width=6)
                                ])
                            ], title="View Advanced Model Constants")
                        ], start_collapsed=True, className="mt-4 shadow-sm")
                    ])
                ])
            ], className="shadow-sm border-0 rounded-3 mb-3")
        ], lg=3, md=12),
        
        # RIGHT MAIN AREA
        dbc.Col([
            dcc.Loading(
                id="loading-spinner", type="dot", color="#198754",
                children=html.Div(id="results-output", children=[
                    html.Div("Select coordinates and click 'Run Simulation'.", className="text-center text-muted mt-5 pt-5")
                ])
            )
        ], lg=9, md=12)
    ])
], fluid=True, className="bg-light pb-5", style={"minHeight": "100vh"})


@app.callback(
    Output('location-input', 'value'),
    Output('layer', 'children'),
    Input('map', 'clickData'),
    prevent_initial_call=True
)
def map_click(clickData):
    if not clickData: return dash.no_update, dash.no_update
    lat = clickData['latlng']['lat']
    lon = clickData['latlng']['lng']
    marker = dl.Marker(position=[lat, lon])
    return f"{lat:.4f}, {lon:.4f}", marker


# --- UPDATED CALLBACK: Now returns data to the hidden store ---
@app.callback(
    Output("results-output", "children"),
    Output("trend-data-store", "data"), 
    Input("run-button", "n_clicks"),
    State("location-input", "value"),
    State("year-input", "value"),
    State("rem-slider", "value"),
    State("storage-slider", "value"),
    State("pv-slider", "value"),
    State("ocm-slider", "value"),
    prevent_initial_call=True
)
def run_model_from_ui(n_clicks, selected_location, selected_year, rem_bounds, storage_bounds, pv_bounds, ocm_bounds):
    if n_clicks is None or not selected_location: return dash.no_update, dash.no_update
        
    try:
        df = matlab_instance.run_optimisation(selected_location, selected_year, rem_bounds, storage_bounds)
        df['Renewable_Share'] = (1 - df['BackupShare']) * 100
        
        df = df[(df['PV_gen_share'] >= pv_bounds[0]/100.0) & (df['PV_gen_share'] <= pv_bounds[1]/100.0)]
        df = df[(df['OcM'] >= ocm_bounds[0]) & (df['OcM'] <= ocm_bounds[1])]
        
        if df.empty:
            raise ValueError("No results found within the chosen bounds. Please widen the filters.")
        
        opt_idx = df['Total_LCOH'].idxmin()
        optimal = df.loc[opt_idx]
        
        lat_val, lon_val = -33.03, 137.56 
        if "," in selected_location:
            lat_val, lon_val = map(float, selected_location.split(","))

        kpi_cards = dbc.Row([
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Minimum LCOH", className="text-muted"), html.H3(f"${optimal['Total_LCOH']:.2f}/kg", className="text-success fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Total Renewable Share", className="text-muted"), html.H3(f"{optimal['Renewable_Share']:.1f}%", className="text-primary fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Optimal Storage", className="text-muted"), html.H3(f"{optimal['Storage_hrs']} hrs", className="text-info fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Optimal REM", className="text-muted"), html.H3(f"{optimal['REM']}x", className="text-warning fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
        ], className="mb-4")
        
        components = ['Storage_LCOH', 'Transport_LCHS', 'GreenHydrogen_LCOH', 'Electricity_LCOH']
        labels = ['Storage Cost', 'Transport Cost', 'Electrolyser Cost', 'Grid Electricity']
        df['Renewable_Bin'] = (df['Renewable_Share'] / 5).round() * 5
        trend_df = df.loc[df.groupby('Renewable_Bin')['Total_LCOH'].idxmin()].sort_values('Renewable_Bin')
        
        fig_trend = go.Figure()
        for comp, name in zip(components, labels):
            percentage = (trend_df[comp] / trend_df['Total_LCOH']) * 100
            fig_trend.add_trace(go.Bar(x=trend_df['Renewable_Bin'], y=percentage, name=name))
            
        fig_trend.add_annotation(
            text=f"<b>Optimal Case Costs:</b><br>Storage: ${optimal['Storage_LCOH']:.3f}/kg<br>Transport: ${optimal['Transport_LCHS']:.3f}/kg",
            align='left', showarrow=False, xref='paper', yref='paper', x=1.02, y=0.4, xanchor='left', yanchor='top',
            bordercolor='#e5e5e5', borderwidth=1, borderpad=10, bgcolor='rgba(248, 249, 250, 0.9)', font=dict(size=12)
        )
        
        fig_trend.update_layout(barmode='stack', title="Relative Cost Breakdown vs. Renewable Share (Click a bar to isolate!)", xaxis_title="Total Renewable Share (%)", yaxis_title="Proportion of Total Cost (%)", template="plotly_white", margin=dict(l=20, r=180, t=40, b=20), clickmode='event+select')
        
        heat_df = df[(df['PV_gen_share'] == optimal['PV_gen_share']) & (df['OcM'] == optimal['OcM'])]
        fig_contour = go.Figure(go.Contour(
            x=heat_df['Storage_hrs'], y=heat_df['REM'], z=heat_df['Total_LCOH'],
            colorscale="Viridis", reversescale=True, contours=dict(showlabels=True)
        ))
        fig_contour.update_layout(title=f"2D Sizing Hotspot (Solar={optimal['PV_gen_share']*100:.0f}%, OcM={optimal['OcM']}x)", xaxis_title="Storage Capacity (Hours)", yaxis_title="Renewable Energy Multiple (REM)", template="plotly_white", margin=dict(l=20, r=20, t=40, b=20))
        
        lat100, lon100 = get_radius_coords(lat_val, lon_val, 100)
        lat50, lon50 = get_radius_coords(lat_val, lon_val, 50)
        
        fig_map = go.Figure()
        fig_map.add_trace(go.Scattermapbox(lat=lat100, lon=lon100, mode='lines', fill='toself', fillcolor='rgba(25, 135, 84, 0.15)', line=dict(color='rgba(25, 135, 84, 0.5)', width=2), name="100km Feasibility Zone"))
        fig_map.add_trace(go.Scattermapbox(lat=lat50, lon=lon50, mode='lines', fill='toself', fillcolor='rgba(25, 135, 84, 0.3)', line=dict(color='rgba(25, 135, 84, 0.8)', width=2), name="50km Core Zone"))
        fig_map.add_trace(go.Scattermapbox(lat=[lat_val], lon=[lon_val], mode='markers', marker=go.scattermapbox.Marker(size=12, color='red'), name="Optimal Plant Base", text=[f"Center LCOH: ${optimal['Total_LCOH']:.2f}"], hoverinfo="text"))
        
        fig_map.update_layout(mapbox_style="open-street-map", mapbox=dict(center=dict(lat=lat_val, lon=lon_val), zoom=7), title="100km Spatial Feasibility & Distribution Contour", margin=dict(l=0, r=0, t=40, b=0))

        raw_data_table = dbc.Accordion([
            dbc.AccordionItem([
                dash_table.DataTable(
                    data=optimal.to_frame().T.to_dict('records'),
                    style_table={'overflowX': 'auto'},
                    style_cell={'textAlign': 'left', 'padding': '10px', 'fontFamily': 'sans-serif'},
                    style_header={'backgroundColor': '#f8f9fa', 'fontWeight': 'bold'}
                )
            ], title="View Raw Numerical Results (Optimal Configuration)")
        ], start_collapsed=True, className="mt-4 shadow-sm")

        # Serialise the trend dataframe into JSON for the modal to use later
        trend_json = trend_df.to_json(orient='split')

        dashboard_layout = html.Div([
            kpi_cards,
            dbc.Row([
                # ADDED ID "trend-graph" TO ENABLE CLICK LISTENING
                dbc.Col(dbc.Card(dcc.Graph(id="trend-graph", figure=fig_trend), className="border-0 shadow-sm rounded-3 mb-4"), lg=12, md=12),
            ]),
            dbc.Row([
                dbc.Col(dbc.Card(dcc.Graph(figure=fig_contour), className="border-0 shadow-sm rounded-3 mb-4"), lg=6, md=12),
                dbc.Col(dbc.Card(dcc.Graph(figure=fig_map), className="border-0 shadow-sm rounded-3 mb-4"), lg=6, md=12),
            ]),
            raw_data_table
        ])
        
        return dashboard_layout, trend_json
        
    except Exception as e:
        return dbc.Alert([html.H5("Simulation Error"), html.P(str(e))], color="danger"), dash.no_update


# --- NEW CALLBACK: Listens for a graph click and opens the Drill-Down Modal ---
@app.callback(
    Output("drilldown-modal", "is_open"),
    Output("drilldown-title", "children"),
    Output("drilldown-body", "children"),
    Input("trend-graph", "clickData"),
    State("trend-data-store", "data"),
    prevent_initial_call=True
)
def open_drilldown_modal(clickData, stored_data):
    if not clickData or not stored_data:
        return dash.no_update, dash.no_update, dash.no_update

    # Extract which bar (Renewable Bin) the user clicked on
    clicked_bin = clickData['points'][0]['x']

    # Load the hidden JSON data back into a Pandas DataFrame
    df = pd.read_json(io.StringIO(stored_data), orient='split')
    
    # Filter down to the exact row the user clicked
    row = df[df['Renewable_Bin'] == clicked_bin].iloc[0]

    components = ['Storage_LCOH', 'Transport_LCHS', 'GreenHydrogen_LCOH', 'Electricity_LCOH']
    labels = ['Storage Cost', 'Transport Cost', 'Electrolyser Cost', 'Grid Electricity']
    values = [row[c] for c in components]

    # Build a beautiful, isolated Pie Chart
    fig_pie = go.Figure(data=[go.Pie(labels=labels, values=values, hole=.4, textinfo='label+percent')])
    fig_pie.update_layout(
        title=dict(text=f"Absolute Cost Breakdown (${row['Total_LCOH']:.2f}/kg)", x=0.5),
        margin=dict(t=50, b=10, l=10, r=10)
    )

    # Build the HTML body of the pop-out window
    modal_body = html.Div([
        dcc.Graph(figure=fig_pie, config={'displayModeBar': False}),
        html.Hr(),
        html.H6("Exact Financial Breakdown:", className="fw-bold"),
        dbc.Table([
            html.Thead(html.Tr([html.Th("Component"), html.Th("Cost ($/kg)")])),
            html.Tbody([
                html.Tr([html.Td(labels[i]), html.Td(f"${values[i]:.3f}")]) for i in range(len(labels))
            ])
        ], bordered=True, hover=True, size="sm")
    ])

    modal_title = f"Isolated Analysis: {clicked_bin}% Renewable Share"

    return True, modal_title, modal_body


if __name__ == '__main__':
    app.run_server(debug=True)