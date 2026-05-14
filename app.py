import time
import dash
from dash import dcc, html, Input, Output, State
import dash_bootstrap_components as dbc
from matlab_bridge import matlab_instance

# Initialize Dash App with Bootstrap Theme
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.FLATLY])
app.title = "H₂ / Steel Optimisation Console"

# --- Tooltip Components ---
def create_tooltip_label(id_string, label_text, tooltip_text):
    return html.Div([
        html.Span(label_text, id=id_string, style={"textDecoration": "underline", "cursor": "help", "fontWeight": "bold"}),
        dbc.Tooltip(tooltip_text, target=id_string, placement="right")
    ], className="mb-2")

# --- UI Layout ---
app.layout = dbc.Container([
    # Header
    dbc.Row([
        dbc.Col(html.H2("H₂ / Steel Optimisation Console", className="text-primary mt-4 mb-4"))
    ]),
    
    dbc.Row([
        # Left Column: Inputs
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Model Parameters"),
                dbc.CardBody([
                    create_tooltip_label("lbl-pv", "PV Gen Share (0.0 - 1.0)", "The proportion of total renewable capacity allocated to Solar PV vs Wind."),
                    dcc.Slider(id="input-pv", min=0, max=1, step=0.01, value=0.43, marks={0: '0', 1: '1'}),
                    html.Br(),
                    
                    create_tooltip_label("lbl-ratio", "ReM/OcM Ratio", "Ratio between Renewable Energy Multiple and Operation capacity."),
                    dcc.Input(id="input-ratio", type="number", value=0.4, step=0.1, className="form-control"),
                    html.Br(),

                    create_tooltip_label("lbl-rem", "REM (Oversizing Factor)", "An oversizing factor. REM 3.0 means renewables capacity is 3x the electrolyser demand."),
                    dcc.Input(id="input-rem", type="number", value=3.4, step=0.1, className="form-control"),
                    html.Br(),

                    create_tooltip_label("lbl-storage", "Storage Hours", "The duration the energy storage can run the facility at full load without wind/sun."),
                    dcc.Input(id="input-storage", type="number", value=19, step=1, className="form-control"),
                    html.Br(),

                    dbc.Button("Run Optimization", id="btn-run", color="primary", className="w-100 mt-3"),
                    html.Div(id="status-text", className="text-muted mt-2 text-center")
                ])
            ], className="shadow-sm")
        ], md=4),

        # Right Column: Outputs
        dbc.Col([
            dbc.Row([
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            create_tooltip_label("lbl-lcoh-green", "Green H₂ LCOH ($/kg)", "The break-even price of Green Hydrogen covering lifetime CAPEX/OPEX."),
                            html.H3(id="out-green-lcoh", children="---")
                        ])
                    ], className="shadow-sm mb-3")
                ], md=6),
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            create_tooltip_label("lbl-lcos", "Steel LCOS ($/t)", "Comprehensive break-even cost to produce one metric tonne of green steel."),
                            html.H3(id="out-steel-lcos", children="---")
                        ])
                    ], className="shadow-sm mb-3")
                ], md=6),
            ]),
            dbc.Row([
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            create_tooltip_label("lbl-lcoe", "Electricity LCOE ($/MWh)", "Average net present cost of raw electricity generation over asset lifetime."),
                            html.H3(id="out-elec-lcoe", children="---")
                        ])
                    ], className="shadow-sm mb-3")
                ], md=6),
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            create_tooltip_label("lbl-storage-cost", "Storage LCOH ($/kg)", "Portion of the levelized cost directly attributed to the storage system."),
                            html.H3(id="out-storage", children="---")
                        ])
                    ], className="shadow-sm mb-3")
                ], md=6),
            ]),
            dbc.Row([
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            html.Span("Required Grid Backup Energy", style={"fontWeight": "bold"}),
                            html.H4(id="out-backup", children="---")
                        ])
                    ], className="shadow-sm mb-3")
                ])
            ])
        ], md=8)
    ])
], fluid=True, className="p-4 bg-light", style={"minHeight": "100vh"})


# --- Application Callbacks ---
@app.callback(
    [Output("out-green-lcoh", "children"),
     Output("out-steel-lcos", "children"),
     Output("out-elec-lcoe", "children"),
     Output("out-storage", "children"),
     Output("out-backup", "children"),
     Output("status-text", "children")],
    [Input("btn-run", "n_clicks")],
    [State("input-pv", "value"),
     State("input-ratio", "value"),
     State("input-rem", "value"),
     State("input-storage", "value")],
    prevent_initial_call=True
)
def execute_model(n_clicks, pv_share, ratio, rem, storage):
    print("\n--- INITIATING NEW OPTIMIZATION ---")
    print(f"1. Python sending to MATLAB: PV={pv_share}, Ratio={ratio}, REM={rem}, Storage={storage}h")

    start_time = time.time()
    
    # Call the MATLAB Engine Bridge
    results = matlab_instance.run_single_case(pv_share, ratio, rem, storage)

    calc_time = time.time() - start_time
    print(f"2. MATLAB calculation complete in {calc_time:.4f} seconds.")
    print(f"3. Raw data returned: {results}")
    
    if results is None:
        return "Error", "Error", "Error", "Error", "Error", "Execution failed. Check console."
        
    return (
        f"${results['GreenHydrogen_LCOH']:.2f}",
        f"${results['Steel_LCOS']:.2f}",
        f"${results['Electricity_LCOE']:.2f}",
        f"${results['Storage_LCOH']:.2f}",
        f"{results['Backup']:.2f} MWh",
        "Run Complete."
    )

if __name__ == "__main__":
    app.run(debug=True, port=8050)