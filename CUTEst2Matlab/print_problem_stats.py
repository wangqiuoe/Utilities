import pandas as pd
from pandas import DataFrame

def filter(max_n_var = None):
    #probs = {}
    #with open('problem_info.txt','r') as f:
    #    for line in f:
    #        # ALLINITU, variables =        4, equality =        0, inequality =        0, bounds =        0
    #        line = line.strip()
    #        line = line.split(',')
    #        name = line[0].strip()
    #        n_var = int(line[1].split('=')[1].strip())
    #        probs[name] = n_var
    #x = {'n_var':probs}
    #df = DataFrame(x)
    df = pd.read_csv('trace_output_1221_copy/new_measure_trntcg.txt', sep='\t', names=['problem0', 'n1', 'status2', 'time3','g_evals4','f_evals5', 'Hv_evals6', 'f7', 'norm_g8', 'outcome9'])
    df = df[['problem0', 'n1']]
    return df

if __name__ == '__main__':
    probs = filter()
    probs['interval'] = pd.cut(probs['n1'], bins = [1, 3, 100, 1000, 5000])
    x = DataFrame()
    x['counts'] = probs['interval'].value_counts().sort_index()
    x['ratio'] = x['counts'] / probs.shape[0]

    import matplotlib.pyplot as plt
    
    # Pie chart, where the slices will be ordered and plotted counter-clockwise:
    labels = x.index
    sizes = x.counts
    
    fig1, ax1 = plt.subplots()
    plt.rcParams.update({'font.size': 15})
    ax1.pie(sizes, labels=labels, autopct='%1.1f%%',startangle=90)
    ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    plt.tight_layout() 
    plt.savefig("prob_stats.png", dpi=300)
