from snakemake.utils import min_version
min_version("6.0")

configfile: "config/config.yaml"

module euro_calliope:
    snakefile: "/euro-calliope/Snakefile"
    config: config["euro-calliope"]

use rule * from euro_calliope as euro_*


URL_ELEC_LAU1 = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/946419/Sub_national_electricity_consumption_statistics_2005-2019.xlsx"
URL_LAU1_UNITS = 'https://opendata.arcgis.com/datasets/69cd46d7d2664e02b30c2f8dcc2bfaf7_0.geojson'
URL_LAU1_CALLIOPE_ZONES= "https://github.com/calliope-project/uk-calliope/blob/84f2a7a1bae2dc94788cc39745ae8d4606a696fe/zones.zip?raw=true"
URL_LOAD = "https://data.open-power-system-data.org/time_series/latest/time_series_60min_singleindex.csv"
URL_GAS_LAU1= "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/853197/gas_LA_stacked.csv"
URL_NUTS3_SHAPEFILE= "https://gisco-services.ec.europa.eu/distribution/v2/nuts/geojson/NUTS_RG_03M_2010_4326_LEVL_3.geojson"
URL_NUTS3_DWELLING= 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/cens_11dwob_r3.tsv.gz'
URL_HOUSEHOLD_ENERGY='https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/nrg_d_hhq.tsv.gz' 

rule download_electricity_datasets:
    message: "Download datasets"
    output: 
        elec_lau1 ="data/elec_lau1.csv",
        lau1_units ="data/lau1_units.geojson",
        calliope_zones ="data/calliope_zones.zip",
        load_profile ="data/load_profile.csv"
    shell: 
        """
        curl -sLo {output.elec_lau1} '{URL_ELEC_LAU1}'
        curl -sLo {output.lau1_units} '{URL_LAU1_UNITS}'
        curl -sLo {output.calliope_zones} '{URL_LAU1_CALLIOPE_ZONES}'
        curl -sLo {output.load_profile} '{URL_LOAD}'
        """
rule unzip_calliope_zones: 
    input: 
        "data/calliope_zones.zip"
    output:
        "data/shapefile/"
    shell: 
        """
        unzip -d data/shapefile data/calliope_zones.zip
        rm data/__MACOSX
        rm data/calliope_zones.zip
        """

rule generate_elec_profile:
    input:
        elec_lau1="data/elec_lau1.csv",
        lau1_units="data/lau1_units.geojson",
        load_profile="data/load_profile.csv", 
    	calliope_zones="data/shapefile",
        pop_uk="data/population-uk.tif"
    params: 
        year = config["year"]
    output: "demand_timeseries/electricity_demand_2014.csv"
    notebook: "notebooks/elec_profile.py.ipynb"

rule download_gas_datasets:
    message: "Download Datasets"
    output: 
        gas_lau1 ="data/gas_lau1.csv"
    shell: 
        "curl -sLo {output.gas_lau1} '{URL_GAS_LAU1}'"
    
rule gas_demand_per_zone:
    input: 
        lau1_units="data/lau1_units.geojson",
        gas_lau1= "data/gas_lau1.csv",
        calliope_zones="data/shapefile",
        pop_uk="data/population-uk.tif"
    params:
        year = config["year"]
    output: "data/gas_demand_zone.csv"
    notebook: "notebooks/regional_gas_demand.py.ipynb"


rule download_dwelling_data:
    message: "Download dwelling datasets"
    output: 
        nuts3_dwelling="data/cens_11dwob_r3.tsv.gz",
        nuts3_shapefile="data/NUTS_RG_03M_2010_4326_LEVL_3.geojson"
    shell:
        """
        curl -sLo {output.nuts3_dwelling} '{URL_NUTS3_DWELLING}'
        curl -sLo {output.nuts3_shapefile} '{URL_NUTS3_SHAPEFILE}'
        """


rule gas_dwelling:
    input: 
        pop_uk="data/population-uk.tif",
        calliope_zones="data/shapefile",
        gas_zones= "data/gas_demand_zone.csv",
        nuts3_shapefile= "data/NUTS_RG_03M_2010_4326_LEVL_3.geojson",
        nuts3_dwelling= "data/cens_11dwob_r3.tsv.gz"
    output: "data/gas_zones_housetypes.csv" 
    notebook: "notebooks/gas_dwelling.py.ipynb"

rule download_household_energy_data:
    message: "Download household energy data"
    output: 
        household_energy ="data/nrg_d_hhq.tsv.gz"
    shell: 
        "curl -sLo {output.household_energy} '{URL_HOUSEHOLD_ENERGY}'"

rule calculate_heat_profiles:
    input:
        household_energy ="data/nrg_d_hhq.tsv.gz",
        gas_zones_housetypes="data/gas_zones_housetypes.csv",
        space_profile="data/demand_profiles/space-heat-profile.csv",
        water_profile="data/demand_profiles/water-heat-profile.csv"
    output:
        heat_timeseries= "demand_timeseries/heat_demand_2014.csv"
    notebook: "notebooks/calculate_heat_profiles.py.ipynb"