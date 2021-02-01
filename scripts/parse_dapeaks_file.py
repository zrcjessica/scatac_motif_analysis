import pandas as pd
import argparse

print('running parse_dapeaks_file.py')

parser = argparse.ArgumentParser(description='Parse input arguments.')
parser.add_argument("--input", action = "store",
	help = "path to input file (da peaks output from Signac FindAllMarkers)")
parser.add_argument("--out", action = "store",
	help = "path to write output")

args = parser.parse_args()
print("args parsed")

peaks = pd.read_csv(args.input, index_col = 0)
print(peaks.head())

# split value in `gene` column to generate `chr`, `start`, and `end` cols
new = peaks.merge(peaks.gene.apply(lambda s: pd.Series({'chr': 'chr'+s.split('-')[0],
	'start': s.split('-')[1],
	'end': s.split('-')[2]})), left_index = True, right_index = True)

print(new.head())
# write to output
new.to_csv(args.out, index = True)
