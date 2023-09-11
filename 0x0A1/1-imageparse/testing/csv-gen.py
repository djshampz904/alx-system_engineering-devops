import csv
import random

# Function to generate a random number between 20 and 50
def generate_random_number():
    return random.randint(20, 50)

# Create a list of days of the week
days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

# Create a list of week names
weeks = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"]

# Create a CSV file and write the data
with open("week_data.csv", mode="w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    
    # Write the header row with day names
    writer.writerow(["Week"] + days_of_week)
    
    # Generate and write data for each week
    for week in weeks:
        row_data = [week] + [generate_random_number() for _ in days_of_week]
        writer.writerow(row_data)

print("CSV file 'week_data.csv' has been created with random data.")

