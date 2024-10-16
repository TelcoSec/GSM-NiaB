from dash import Dash, html, dcc, callback, Output, Input, dash_table
import plotly.express as px
import pandas as pd

df = pd.read_csv('https://raw.githubusercontent.com/plotly/datasets/master/gapminder_unfiltered.csv')

app = Dash()
app.title = "RFS GSM enumeration"
app.layout = [
    html.H1(children='GSM Enumeration', style={'textAlign':'center'}),
    dcc.Dropdown(df.country.unique(), 'Portugal', id='dropdown-selection'),
    dcc.Graph(id='graph-content'),
    dash_table.DataTable(df.to_dict('records'), [{"name": i, "id": i} for i in df.columns])
]

@callback(
    Output('graph-content', 'figure'),
    Input('dropdown-selection', 'value')
)
def update_graph(value):
    dff = df[df.country==value]
    return px.line(dff, x='year', y='pop')

if __name__ == '__main__':
    app.run_server(host= '0.0.0.0',debug=False)
#app.run(debug=True)