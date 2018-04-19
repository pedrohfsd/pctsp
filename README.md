# A Metaheuristic for the PCTSP (Prize-Collecting Traveling Salesman Problem)

This repository contains a simple metaheuristic code for the PCTSP made just for fun/learning/testing purposes.

### What is the PCTSP?

In plain text we can describe it as a generalization of the TSP (Traveling Salesman Problem) where a salesman collects a prize P_i in each city visited and pays a penalty Y_i for each city not visited, considering travel costs C_ij between the cities.

The problem is to minimize the sum of the costs of the tour ([Hamiltonian Cycle](https://en.wikipedia.org/wiki/Hamiltonian_path)) and penalties paid, while including in the tour enough cities to collect a minimum prize P_min, defined a priori.

The formal definition is:
