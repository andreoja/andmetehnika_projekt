# LIIKLUSÕNNETUSTE_ETL

This project needs R, Python and SQLite3.

### **THE DATA**

API that is used here is https://avaandmed.eesti.ee/api/
The documentation can be found here: https://avaandmed.eesti.ee/api/dataset-docs/
Alltogether 3 tables will be downloaded:

- liiklusonnetused: information about accidents in Estonia.
- liiklusloenduse andmed: information about traffic in Estonia.
- liiklusloenduseseadmed: information about features that measure traffic in Estonia.

All the metadata can be found in the links provided in fetch.ipynb

### **1. Open and run fetch.ipynb in Jupyter Notebook**

This notebook will:

- download "liiklusõnnetused_2011_2022"a .csv file from API and save it as "liiklusonnetused.csv" (https://avaandmed.eesti.ee/datasets/inimkannatanutega-liiklusonnetuste-andmed)
- download all files from "liiklusloenduse andmed" the files are saved into folder "liiklusloendus". The folder will be created by script (https://avaandmed.eesti.ee/datasets/liiklusloenduse-andmed)
- downloads liiklusloendusseadmed from (https://avaandmed.eesti.ee/datasets/liiklusloendusseadmed)

### **2. Open and run transform.ipynb in Jupyter Notebook**

This will clean the data and write it into a sqlite3 database

### **3. Open and run closest_traffic_feature.ipynb in Jupyter Notebook**

This will make 2 new columns to liiklusonnetused table. For every row it will look for a closest traffic measuring feature and add it to the table. Then it will calculate the distance between the feature and the place where accident happened.

### 4. Open and run dashboard.r in RStudio

This will run the dashboard which allows you to:

- Filter the data bydate range to display relevant information.
- View a data table showing the selected data.
- Explore the data on an interactive map.
- Visualize the distribution of traffic accidents by accident type using a bar chart.
