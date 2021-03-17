URL_ELEC_LAU1 = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/946419/Sub_national_electricity_consumption_statistics_2005-2019.xlsx"
URL_LAU1_UNITS = 'https://opendata.arcgis.com/datasets/69cd46d7d2664e02b30c2f8dcc2bfaf7_0.geojson'
URL_LAU1_CALLIOPE_ZONES =  "https://github.com/calliope-project/uk-calliope/blob/84f2a7a1bae2dc94788cc39745ae8d4606a696fe/zones.geojson"

rule download_datasets:
    message: "Download datasets"
    output: 
        elec_lau1 = protected("data/elec_lau1.csv"),
        lau1_units = protected("data/lau1_units.geojson"),
        calliope_zones = protected("data/calliope_zones.geojson")
    shell: 
        """
        curl -sLo {output.elec_lau1} '{URL_ELEC_LAU1}'
        curl -sLo {output.lau1_units} '{URL_LAU1_UNITS}'
        curl -sLo {output.calliope_zones} '{URL_LAU1_CALLIOPE_ZONES}'
        """

rule generate_elec_profile:
    input:
        elec_lau1="data/elec_lau1.csv" ,
        lau1_units="data/lau1_units.geojson",
        load_profile_2014="data/load_profile_2014.csv", 
    	calliope_zones="data/calliope_zones.geojson",
        pop_uk="shapefiles/population-uk.tif",
    output: "demand_timeseries/elec_demand.csv"
    notebook: "notebooks/elec_profile.py.ipynb" 





