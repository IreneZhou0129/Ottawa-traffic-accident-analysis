import pandas as pd  
import numpy as np
from sqlalchemy import create_engine
import psycopg2 
from io import BytesIO as StringIO
from datetime import date 
from datetime import datetime 
import calendar

engine = create_engine('postgresql+psycopg2://UserName:Password@web0.eecs.uottawa.ca:15432/group_7')

df = pd.read_csv('CollisionData2.csv', sep='\t', header=None)
#old_df = pd.read_csv('../project/CollisionData.csv')

# add headers to the original csv file
df.columns = ["streetName","intersection_1","intersection_2","longitude","latitude",
              "year","month","date","time","10","Environment","Road_Surface","Traffic_Control","Collision_Location","Light","Collision_Classification","Impact_type"]

def accident_dimension():

    # copy the columns that Location needs
    time = df["time"].copy()
    environment = df["Environment"].copy()
    road_surface = df["Road_Surface"].copy()
    traffic_control = df["Traffic_Control"].copy()
    collision_location = df["Collision_Location"].copy()
    light = df["Light"].copy()
    collision_classification = df["Collision_Classification"].copy()
    impact_type = df["Impact_type"].copy()

    accident_attributes = []
    accident_attributes = [time, environment, road_surface, traffic_control, collision_location, light, collision_classification, impact_type]

    # concatenate all df into one Location dataframe
    accident_df = pd.concat(accident_attributes, axis=1)

    return accident_df

# curr_table = 'locations', type is str
def save_to_db(curr_df, curr_table):

    # save values in the Location dataframe into postgreDB
    curr_df.head().to_sql(curr_table, engine, if_exists='replace',index=False) 

    conn = engine.raw_connection()
    cur = conn.cursor()
    output = StringIO()

    curr_df.to_csv(output, sep='\t', header=False, index=False, encoding='ascii')
    output.seek(0)

    cur.copy_from(output, curr_table, null="") # null values become ''
    conn.commit()
    return

# hour_start/   hour_end/   date/   day_of_week/ 
# month/    year/     
# is_weekend/     is_holiday/     holiday_name

# Convert a date in type-string to type-date
# input =  "22-08-2017" 
# output = Tuesday 





def main():
    # hour_dimension()
    save_to_db(accident_dimension(), "accident")
    print("done")


if __name__ == '__main__':
    main()
