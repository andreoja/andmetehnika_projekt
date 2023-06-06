# andmetehnika_projekt

### **1. CREATE SQLITE3 DATABASE**

In this Project sqlite3 database named "database.db" has to be created

### **2. RUN fetch.ipynb**

API that is used here is https://avaandmed.eesti.ee/api/

the documentation can be found here: https://avaandmed.eesti.ee/api/dataset-docs/

The notebook will:

1. download "liiklusõnnetused_2011_2022"a .csv file from API and save it as liiklusonnetused.csv https://avaandmed.eesti.ee/datasets/inimkannatanutega-liiklusonnetuste-andmed
2. download all files from "liiklusloenduse andmed" the files are saved into folder liiklusloendus https://avaandmed.eesti.ee/datasets/liiklusloenduse-andmed
3. downloads liiklusloendusseadmed from https://avaandmed.eesti.ee/datasets/liiklusloendusseadmed

### 3. RUN transform.ipynb

This will clean the data and write it into a sqlite3 database
