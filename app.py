import dash
from dash import dcc, html, Input, Output, State
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
from matlab_bridge import matlab_instance

# Initialize the Dash app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.LUMEN, dbc.icons.BOOTSTRAP])

# --- LAYOUT ---
app.layout = dbc.Container([
    dbc.Row([
        dbc.Col(html.H2(
            [html.I(className="bi bi-globe-americas text-success me-2"), "Global Green Hydrogen Insights"], 
            className="fw-bold my-4 text-dark"
        ), width=12)
    ]),
    
    dbc.Row([
        # LEFT SIDEBAR: Controls
        dbc.Col([
            dbc.Card([
                dbc.CardHeader(html.H5("Scenario Parameters", className="m-0 fw-bold")),
                dbc.CardBody([
                    html.Label("Target Location (Any City)", className="fw-semibold text-muted small"),
                    # Changed from Dropdown to a free-text Input
                    dcc.Input(
                        id='location-input',
                        type='text',
                        placeholder='e.g., Tokyo, Berlin, Sydney...',
                        value='Whyalla',
                        className="form-control mb-4 shadow-sm"
                    ),
                    
                    html.Label("Analysis Year", className="fw-semibold text-muted small"),
                    dcc.Input(
                        id='year-input',
                        type='number',
                        value=2020,
                        min=1940, # Open-Meteo historical data goes back to 1940
                        max=2024,
                        step=1,
                        className="form-control mb-4 shadow-sm"
                    ),
                    
                    dbc.Button(
                        [html.I(className="bi bi-play-fill me-2"), "Run Simulation"], 
                        id="run-button", 
                        color="success", 
                        className="w-100 fw-bold shadow-sm"
                    )
                ])
            ], className="shadow-sm border-0 rounded-3 mb-4")
            
            # NOTE: Terminology alert has been removed from here!
            
        ], lg=3, md=12),
        
        # RIGHT MAIN AREA: Results Dashboard
        dbc.Col([
            # Set type="dot" to create the 3 pulsing ellipses (...)
            dcc.Loading(
                id="loading-spinner",
                type="dot", 
                color="#198754",
                children=html.Div(id="results-output", children=[
                    html.Div(
                        "Enter any global city and click 'Run Simulation' to fetch API data and generate insights.", 
                        className="text-center text-muted mt-5 pt-5"
                    )
                ])
            )
        ], lg=9, md=12)
    ])
], fluid=True, className="bg-light pb-5", style={"minHeight": "100vh"})


# --- CALLBACK ---
@app.callback(
    Output("results-output", "children"),
    Input("run-button", "n_clicks"),
    State("location-input", "value"),
    State("year-input", "value"),
    prevent_initial_call=True
)
def run_model_from_ui(n_clicks, selected_location, selected_year):
    if n_clicks is None or not selected_location:
        return dash.no_update
        
    try:
        df = matlab_instance.run_optimisation(location=selected_location, year=selected_year)
        
        opt_idx = df['Total_LCOH'].idxmin()
        optimal = df.loc[opt_idx]
        
        # KPI Cards
        kpi_cards = dbc.Row([
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Minimum LCOH", className="text-muted"), html.H3(f"${optimal['Total_LCOH']:.2f}/kg", className="text-success fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Optimal Solar Share", className="text-muted"), html.H3(f"{optimal['PV_gen_share']*100:.0f}%", className="text-primary fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Optimal Storage", className="text-muted"), html.H3(f"{optimal['Storage_hrs']} hrs", className="text-info fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
            dbc.Col(dbc.Card(dbc.CardBody([html.H6("Optimal REM", className="text-muted"), html.H3(f"{optimal['REM']}x", className="text-warning fw-bold")]), className="border-0 shadow-sm rounded-3"), width=3),
        ], className="mb-4")
        
        # Stacked Bar
        components = ['Storage_LCOH', 'GreenHydrogen_LCOH', 'Transport_LCHS', 'Electricity_LCOH']
        labels = ['Storage Cost', 'Electrolyser Cost', 'Transport Cost', 'Grid Electricity']
        fig_bar = go.Figure(data=[go.Bar(name=labels[i], x=['Optimal Configuration'], y=[optimal[comp]]) for i, comp in enumerate(components)])
        fig_bar.update_layout(barmode='stack', title="LCOH Breakdown", template="plotly_white", margin=dict(l=20, r=20, t=40, b=20))
        
        # Scatter Plot
        fig_scatter = px.scatter(
            df, x="BackupShare", y="Total_LCOH", color="PV_gen_share", 
            title="System Cost vs Grid Reliance",
            labels={"BackupShare": "Grid Backup Required (%)", "Total_LCOH": "Total LCOH ($)", "PV_gen_share": "Solar Share"}
        )
        fig_scatter.update_layout(template="plotly_white", margin=dict(l=20, r=20, t=40, b=20))
        
        # Heatmap
        heat_df = df[(df['REM'] == optimal['REM']) & (df['OcM'] == optimal['OcM'])]
        heat_pivot = heat_df.pivot_table(index="Storage_hrs", columns="PV_gen_share", values="Total_LCOH", aggfunc="min")
        fig_heat = px.imshow(heat_pivot, aspect="auto", color_continuous_scale="Viridis", title=f"Cost Heatmap (REM={optimal['REM']}x)")
        fig_heat.update_layout(template="plotly_white", margin=dict(l=20, r=20, t=40, b=20))
        
        return html.Div([
            kpi_cards,
            dbc.Row([
                dbc.Col(dbc.Card(dcc.Graph(figure=fig_bar), className="border-0 shadow-sm rounded-3 mb-4"), lg=4, md=12),
                dbc.Col(dbc.Card(dcc.Graph(figure=fig_scatter), className="border-0 shadow-sm rounded-3 mb-4"), lg=8, md=12),
            ]),
            dbc.Row([
                dbc.Col(dbc.Card(dcc.Graph(figure=fig_heat), className="border-0 shadow-sm rounded-3 mb-4"), lg=12, md=12)
            ])
        ])
        
    except Exception as e:
        return dbc.Alert([html.H5("Simulation Error"), html.P(str(e))], color="danger")

if __name__ == '__main__':
    app.run_server(debug=True)