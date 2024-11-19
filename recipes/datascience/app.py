import pandas as pd

plot_opts = {
    'figsize': (15, 10),
    'linewidth': 2,
    'kind': 'line',
    'legend': True,
    'fontsize': 22
}

legend_opts = {
    'fontsize': 20,
    'loc': 'upper right'
}

inventory = pd.read_csv("inventory.csv")

inventory["Price"].mean()

inventory.plot(**plot_opts).legend(**legend_opts)
