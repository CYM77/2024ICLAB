import random as rd
import random
from datetime import datetime, timedelta

rd.seed(1234)

def generate_date_lookup_table(start_date, end_date):
    date_lookup = {}

    current_date = start_date
    while current_date <= end_date:
        month = current_date.month
        day = current_date.strftime("%d")

        if month not in date_lookup:
            date_lookup[month] = []

        date_lookup[month].append(day)
        current_date += timedelta(days=1)

    return date_lookup

def random_date_from_lookup(lookup_table):
    random_month = random.choice(list(lookup_table.keys()))
    random_day   = random.choice(lookup_table[random_month])
    return int(random_month),int(random_day)

# Define your desired date range
start_date = datetime(2021, 1, 1)
end_date = datetime(2023, 12, 31)

# Generate the lookup table
date_lookup_table = generate_date_lookup_table(start_date, end_date)

# Randomly pick a date and month from the lookup table

# Print the randomly picked date
# print("Randomly Picked Date:", random_date)
# print(random_date)

DRINK_CAP_MIN = 0
DRINK_CAP_MAX = 4095

fout = open("DRAM/dram.dat", "w")

def DRAM_data():
    # Drink data
    for addr in range(0x10000, 0x107fc, 8):
        # print("---------------")
        # addr
        fout.write('@' + format(addr, 'x') + '\n')

        # Generate random date
        random_date = random_date_from_lookup(date_lookup_table)
        month = random_date[0]
        day   = random_date[1]

        # Note only the month and date needed to be constrainted
        # Write expired day (D) first
        day_hex = '{:0>2x}'.format(day, 'x')
        # print(day_hex)
        fout.write(day_hex + ' ')

        # Write Milk and Pineapple data
        for _ in range(3):
            milk_pine_hex = '{:0>2x}'.format(rd.randint(0,255), 'x')
            # print(milk_pine_hex)
            fout.write(milk_pine_hex + ' ')

        fout.write("\n")

        # addr
        fout.write('@' + format(addr+4, 'x') + '\n')

        # Write expired month
        month_hex = '{:0>2x}'.format(month, 'x')
        # print(month_hex)
        fout.write(month_hex + ' ')

        # Write green tea black tea
        for _ in range(3):
            green_tea_black_tea_hex = '{:0>2x}'.format(rd.randint(0,255), 'x')
            fout.write(green_tea_black_tea_hex + ' ')

        fout.write("\n")

    fout.write('\n')

DRAM_data()