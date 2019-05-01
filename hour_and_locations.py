import pandas as pd
import numpy as np
import json
from pandas.io.json import json_normalize
from shapely.geometry import Point, Polygon, MultiPolygon
from sqlalchemy import create_engine
import psycopg2
from io import BytesIO as StringIO
from datetime import date
from datetime import datetime
import calendar
import holidays

# Connect to the database
engine = create_engine(
    'postgresql+psycopg2://userName:password@web0.eecs.uottawa.ca:15432/group_7')

# Read the CSV file
df = pd.read_csv('CollisionData2.csv', sep='\t', header=None)

# Add headers to the original csv file
df.columns = [
    "street_name",
    "intersection_1",
    "intersection_2",
    "longitude",
    "latitude",
    "year",
    "month",
    "date",
    "time",
    "start_hour",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16"]

ca_holidays = holidays.CA()

# ==============================================================================
#  location_dimension() helper functions:
# ==============================================================================

# ========================================
# parse_json() helper functions: Transform the list to the
# Polygon/MultiPolygon type


def to_polygon(origin_list):

    points_list = []
    for i in origin_list:
        # Drop 0.0 each raw data: [[-75.652699999969, 45.41031799991437, 0.0],
        # ...]
        i.remove(0.0)
        curr_point = Point(i[0], i[1])
        points_list.append(curr_point)

    polygon = Polygon([[p.x, p.y] for p in points_list])

    return polygon


def to_multiPolygon(origin_list, n_parts):

    mp_list = []
    for i in range(n_parts):
        curr = to_polygon(origin_list[i][0])
        mp_list.append(curr)

    multiPolygon = MultiPolygon(mp_list)

    return multiPolygon
# ========================================


# Give a Point and return its neighbourhood's name
def find_neighbourhood(pt, dictionary):

    name = ''
    for k, v in dictionary.items():

        # Case: Polygon
        if(isinstance(v, Polygon)):
            if(v.contains(pt)):

                name = k

        # Case: MultiPolygon
        else:
            for i in v:
                if(i.contains(pt)):

                    name = k

    return name


# Save neighbourhood's name and its boundaries into a dictionary
def parse_json():

    # read the file
    with open('ottawaBoundaries.json') as json_file:
        json_data = json.load(json_file)

    num_of_names = len(json_data["features"])

    names_list = []
    polygons_list = []

    for i in range(num_of_names):

        # Save all neighbourhood names in to a list
        curr_name = json_data["features"][i]["properties"]["Name"]
        names_list.append(curr_name)

        polygon_status = json_data["features"][i]["geometry"]["type"]

        # Save all neighbourhood coordinates in to a list
        curr_coordinates = json_data["features"][i]["geometry"]["coordinates"]

        # Case: Polygon
        if(polygon_status == "Polygon"):

            curr_coordinates = curr_coordinates[0]
            # Convert each raw data to Polygon
            curr_polygons = to_polygon(curr_coordinates)
            polygons_list.append(curr_polygons)

        # Case: MultiPolygon
        if(polygon_status == "MultiPolygon"):

            num_sub_polygons = len(
                json_data["features"][i]["geometry"]["coordinates"])
            # Convert to MultiPolygon
            curr_multiPolygons = to_multiPolygon(
                curr_coordinates, num_sub_polygons)
            polygons_list.append(curr_multiPolygons)

    # Create the dictionary
    #  keys: names
    #  values: boundaries
    dictionary = dict(zip(names_list, polygons_list))

    return dictionary

# ================================================================
# Location Dimension:
# ================================================================


def location_dimension():

    # copy the columns that Location needs
    streetName = df["street_name"].copy().apply(lambda x: x.strip() if type(x) is str else x)
    intersection_1 = df["intersection_1"].copy().apply(lambda x: x.strip() if type(x) is str else x)
    intersection_2 = df["intersection_2"].copy().apply(lambda x: x.strip() if type(x) is str else x)
    longitude = df["longitude"].copy()
    latitude = df["latitude"].copy()

    location_attributes = []
    location_attributes = [
        streetName,
        intersection_1,
        intersection_2,
        longitude,
        latitude]

    # concatenate all df into one Location dataframe
    location_df = pd.concat(location_attributes, axis=1)

    # ===================================================
    # neighbourhood part:

    # generate the boundary dictionary
    name_boundary_dict = parse_json()

    # Goal: combine longitude and latitude into a list then convert to a Point
    # note: put 'a', 'b' instead of 'lon' and 'lat' because of the alphabetical order effects
    # Create a tmp dataframe to calculate the neighbourhood names
    d = {'a': longitude, 'b': latitude}
    lonlat_df = pd.DataFrame(data=d)
    lonlat_df['lonlat_list'] = lonlat_df.values.tolist()
    lonlat_df['Point'] = lonlat_df['lonlat_list'].apply(lambda x: Point(x))
    lonlat_df['Neighbourhood'] = lonlat_df['Point'].apply(
        lambda x: find_neighbourhood(x, name_boundary_dict))

    # Save the Neighbourhood column into the location dataframe
    location_df['Neighbourhood'] = lonlat_df['Neighbourhood']
    # ====================================================

    return location_df

# =========================================================
#  hour_dimension() helper functions:


# input =  "22 08 2017"
# output = Tuesday
def date_to_day(curr_date_str):

    curr_date = datetime.strptime(curr_date_str, '%d %m %Y')
    res = calendar.day_name[curr_date.weekday()]

    return res


# input =  "22 08 2017"
# output = True or False
def holiday_check(curr_date_str):

    curr_date = datetime.strptime(curr_date_str, '%d %m %Y')
    res = (curr_date in ca_holidays)

    return res


def holiday_name(curr_date_str):

    curr_date = datetime.strptime(curr_date_str, '%d %m %Y')
    res = ca_holidays.get(curr_date)

    return res
# =========================================================

# ================================================================
# Hour Dimension:
# ================================================================


def hour_dimension():

    day_cols = []

    # fill 0 into number smaller tham 10
    # e.g., change 8 to 08
    df['month'] = df['month'].map(str).str.zfill(2)
    df['date'] = df['date'].map(str).str.zfill(2)

    year_ = df["year"].copy()
    month_ = df["month"].copy()
    date_ = df["date"].copy()
    time_ = df["time"].copy()

    day_cols = [year_, month_, date_, time_]
    day_df = pd.concat(day_cols, axis=1)

    day_df["hour_start"] = df["start_hour"].copy()
    day_df["hour_end"] = df["start_hour"].apply(lambda x: x + 1)
    day_df["full_date"] = df["date"].map(
        str) + " " + df["month"].map(str) + " " + df["year"].map(str)  # '22 08 2017'
    day_df["day_of_week"] = day_df["full_date"].apply(lambda x: date_to_day(x))
    day_df["is_weekend"] = day_df["day_of_week"].apply(
        lambda x: "Y" if (x == ("Saturday" or "Sunday")) else "N")
    day_df["is_holiday"] = df["date"].apply(
        lambda x: "Y" if (holiday_check) else "N")
    day_df["holiday_name"] = day_df["full_date"].apply(
        lambda x: holiday_name(x))

    return day_df

# ================================================================
#   Save dataframe to postgreDB:
# ================================================================
# curr_table = 'locations', type is str


def save_to_db(curr_df, curr_table):

    # save values in the Location dataframe into postgreDB
    curr_df.head().to_sql(curr_table, engine, if_exists='replace', index=False)

    conn = engine.raw_connection()
    cur = conn.cursor()
    output = StringIO()

    curr_df.to_csv(
        output,
        sep='\t',
        header=False,
        index=False,
        encoding='ascii')
    output.seek(0)

    cur.copy_from(output, curr_table, null="")  # null values become ''
    conn.commit()
    return


# ================================================================
#  Insert 'Neighbourhood' data in the 'locations' table
# ================================================================

# input:    str_list = ["apple","pear","berry"]; output:
# "('apple'),('pear'),('berry')"
def do_string(str_list):

    str_list = [v.replace("'", "_") if ("'" in v) else v for v in str_list]

    result = ', '.join('(\'{0}\')'.format(w) for w in str_list)
    return result


def get_neibourhood_list(curr_df):

    name_list = curr_df['Neighbourhood'].tolist()

    # Convert each unicode item into string
    str_list = [x.encode('UTF8') for x in name_list]

    return str_list


def update_locations(str_list):

    values = do_string(str_list)

    statement = 'insert into test2 (nbh) values ' + values

    conn = engine.raw_connection()
    cur = conn.cursor()

    cur.execute(statement)

    conn.commit()

    cur.close()
# ================================================================


def test2(str_list):

    values = do_string(str_list)

    statement = 'insert into test2 (neighbourhood) values ' + values

    conn = engine.raw_connection()
    cur = conn.cursor()

    cur.execute(statement)

    conn.commit()

    cur.close()

# ================================================================


def main():

    hour_dim = hour_dimension()
    save_to_db(hour_dim, "hours")

    # 
    # print(loc_dim.loc['longitude'])

    loc_dim = location_dimension()
    save_to_db(loc_dim, "locations")
    #string_list = get_neibourhood_list(loc_dim)
    #update_locations(string_list)

    # test2()
    

    print("done")


if __name__ == '__main__':
    main()
