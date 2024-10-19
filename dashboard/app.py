from dash import Dash, html, dcc, callback, Output, Input, dash_table
import dash_mantine_components as dmc
import plotly.express as px
import pandas as pd


from dash_iconify import DashIconify


def get_icon(icon):
    return DashIconify(icon=icon, height=16)


html.Div(
    [
        dmc.NavLink(
            label="IMSI",
            leftSection=get_icon(icon="bi:house-door-fill"),
        ),
        dmc.NavLink(
            label="SMS",
            leftSection=get_icon(icon="tabler:gauge"),
            rightSection=get_icon(icon="tabler-chevron-right"),
        ),
        dmc.NavLink(
            label="BTS",
            leftSection=get_icon(icon="tabler:circle-off"),
            disabled=True,
        ),
        dmc.NavLink(
            label="ARFCN",
            description="Additional information",
            leftSection=dmc.Badge(
                "3", size="xs", variant="filled", color="red", w=16, h=16, p=0
            ),
        ),
        dmc.NavLink(
            label="Active subtle",
            leftSection=get_icon(icon="tabler:activity"),
            rightSection=get_icon(icon="tabler-chevron-right"),
            variant="subtle",
            active=True,
        ),
        dmc.NavLink(
            label="Active light",
            leftSection=get_icon(icon="tabler:activity"),
            rightSection=get_icon(icon="tabler-chevron-right"),
            active=True,
        ),
        dmc.NavLink(
            label="Active filled",
            leftSection=get_icon(icon="tabler:activity"),
            rightSection=get_icon(icon="tabler-chevron-right"),
            variant="filled",
            active=True,
        ),
    ],
    style={"width": 240},
)

df = pd.read_csv('268.csv')

app = Dash()
app.title = "RFS GSM enumeration"
app.layout = [
    html.H1(children='GSM Enumeration', style={'textAlign':'center'}),
    dmc.Alert(
       "Hi from Dash Mantine Components. You can create some great looking dashboards using me!",
       title="Welcome!",
       color="violet",
    ),
    dcc.Dropdown(df.radio.unique(), 'GSM', id='dropdown-selection'),
    dcc.Graph(id='graph-content'),
    dash_table.DataTable(df.to_dict('records'), [{"name": i, "id": i} for i in df.columns])
]

@callback(
    Output('graph-content', 'figure'),
    Input('dropdown-selection', 'value')
)
def update_graph(value):
    dff = df[df.radio==value]
    return px.line(dff, x='mcc', y='net')

if __name__ == '__main__':
    app.run_server(host= '0.0.0.0',debug=False)
#app.run(debug=True)
