import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib

plt.style.use('ggplot')
from matplotlib.pyplot import figure

# plt.interactive(True)
# %matplotlib inline
matplotlib.rcParams['figure.figsize'] = (12, 8)

'''-------------------------------------------------------'''
# read in data, using pandas to read data, df for dataframe
df = pd.read_csv('C:\\Users\\jungy\\OneDrive - UBC\\Personal Learning\\Python\\movies.csv')

# Adjust display settings to show all columns
pd.set_option('display.max_columns', None)  # Show all columns
pd.set_option('display.width', None)  # Allow full width for display instead of ...

# change data type of columns
df['budget'] = df['budget'].fillna(0).astype('int64')  # specifics budget column, changes
df['gross'] = df['gross'].fillna(0).astype('int64')  # need to fill null values with 0

# check for missing data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())  # pct = percent, np = numpy
    # print('{} - {}%'.format(col, pct_missing))

# create correct year
# df['correctyear'] = df['released'].astype(str).str[-20:-16]  # only works if it was released in United States
df['correctyear'] = df['released'].astype(str).str.extract(r', (\d{4})')  # extract year from released date

# Drop any duplicates
df.drop_duplicates()
df['company'].sort_values(ascending=False)
# df['company'].drop_duplicates().sort_values(ascending=False)

pd.set_option('display.max_rows', None)  # shows all rows
df = df.sort_values(by=['gross'], inplace=False, ascending=False)
# print(df_sorted)
# pd.reset_option('display.width')

'''Correlation Predictions'''
# Budget high correlation
# Company high correlation

# Scatter plot with budget vs gross
plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget for Film')

# Plot Budget vs Gross using Seaborn: Regression Plot
sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "red"}, line_kws={"color": "blue"})
plt.figure()
plt.show()

numeric_df = df[['budget', 'gross', 'runtime', 'score', 'votes', 'year']]
# print(numeric_df.corr(method='pearson'))  # pearson (default), kendall, spearman
# High correlation between budget and gross

correlation_matrix = numeric_df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')
plt.figure()
plt.show()

# Look at Company
df_numerized = df

for col_name in df_numerized.columns:  # converts string objects into numeric values
    if df_numerized[col_name].dtype == 'object':
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

# print(df_numerized)

correlation_matrix = round(df_numerized.corr(method='pearson'), 2)  # 2 decimal places
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')
plt.figure()
plt.show()

correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack()
# print(corr_pairs)  # shows correlation as a list
sorted_pairs = corr_pairs.sort_values(ascending=False)
# print(sorted_pairs)  # shows year vs correctyear

high_corr = sorted_pairs[0.5 < sorted_pairs]
print(high_corr)
# Votes and gross have high correlation

# data types for columns
# print(df.dtypes)  # checks data types
# print(df['budget'].dtype)
# print(df['gross'].dtype)
# print(df['released'].dtype)
# print(df['released'])
# print(df['correctyear'].dtype)
# print(df['correctyear'])

# look at data
# print(df.head())
# print(df[['name', 'year', 'released', 'budget', 'gross']].head())
# print(df.columns)
# print(df)
