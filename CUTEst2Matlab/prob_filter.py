
def filter(max_n_var = None, output_file = None):
    fout = open(output_file, 'w')
    with open('problem_info.txt','r') as f:
        for line in f:
            # ALLINITU, variables =        4, equality =        0, inequality =        0, bounds =        0
            line = line.strip()
            line = line.split(',')
            name = line[0].strip()
            n_var = int(line[1].split('=')[1].strip())
            if n_var <= max_n_var:
                fout.write(name+'\n')


if __name__ == '__main__':
    filter(max_n_var = 20000, output_file = 'list_prob_nomorethan20000.txt')        
