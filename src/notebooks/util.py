
import pandas as pd
import rasterio

def to_numeric(series):
    series = series.astype(str).str.extract('(\-*\d+\.*\d*)')[0]
    return pd.to_numeric(series, errors='coerce')

def load_eurostat_tsv(path_to_tsv, index_names, slice_idx=None, slice_lvl=None):
    df = pd.read_csv(path_to_tsv, delimiter='\t', index_col=0)
    df.index = df.index.str.split(',', expand=True).rename(index_names)
    if slice_idx is not None:
        df = df.xs(slice_idx, level=slice_lvl)
    #df.columns = df.columns.astype(int)
    return df.apply(to_numeric)

def open_raster(raster):
    with rasterio.open(raster) as pop_grid:
        array = pop_grid.read(1)
        crs = pop_grid.crs
        affine = pop_grid.transform
    return pop_grid