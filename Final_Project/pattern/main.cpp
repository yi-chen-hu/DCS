#include <iostream>
#include <iomanip>
#include <fstream>
#include <random>
#include <vector>

using namespace std;

#define TIME 1
#define PATNUM 100

void reverseArray(vector<int>& arr, int start, int end)
{
	while (start < end)
	{
		int temp = arr[start];
		arr[start] = arr[end];
		arr[end] = temp;
		start++;
		end--;
	}
}

int main()
{
	for (int t = 0; t < TIME; t++)
	{
		srand(10);

		ofstream input;
		ofstream output;
		input.open("input1.txt");
		output.open("output1.txt");

		for (int patcount = 0; patcount < PATNUM; patcount++)
		{
			vector<int> cost;
			cost.clear();
			cost.resize(64);

			vector<int> job;
			job.clear();
			job.resize(8);

			vector<int> bestJob;
			bestJob.clear();
			bestJob.resize(8);

			int minCost;

			int p; //´À´«ÂI

			for (int i = 0; i < cost.size(); i++)
			{
				if (i % 8 == 0 && i != 0)
					input << endl;
				cost[i] = rand() % 128;
				//write input
				if (i % 8 == 0)
					input << cost[i];
				else
					input << setw(4) << cost[i];
			}
			input << endl;

			for (int i = 0; i < job.size(); i++)
			{
				job[i] = i;
			}

			minCost = cost[0 + job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]]
				+ cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]];

			for (int i = 0; i < bestJob.size(); i++)
			{
				bestJob[i] = job[i];
			}
			
			while (true)
			{
				int sum = cost[0 + job[0]] + cost[8 + job[1]] + cost[16 + job[2]] + cost[24 + job[3]]
					+ cost[32 + job[4]] + cost[40 + job[5]] + cost[48 + job[6]] + cost[56 + job[7]];
				/*
				if (job[0] == 3 && job[1] == 1 && job[2] == 5 && job[3] == 2 && job[4] == 6 && job[5] == 7 && job[6] == 4 && job[7] == 0)
				{
					cout << sum << endl;
					system("pause");
				}	
				*/
				if (sum < minCost)
				{
					minCost = sum;
					for (int i = 0; i < bestJob.size(); i++)
					{
						bestJob[i] = job[i];
					}
				}

				//job == {7, 6, 5, 4, 3, 2, 1, 0}
				if (job[0] == 7 && job[1] == 6 && job[2] == 5 && job[3] == 4
					&& job[4] == 3 && job[5] == 2 && job[6] == 1 && job[7] == 0)
				{
					break;
				}

				//algorithm here

				//looking for p
				
				for (int i = 6; i >= 0; i--)
				{
					if (job[i] < job[i + 1])
					{
						p = i;
						//cout << "p = " << p << endl;
						break;
					}
				}
				
				//looking for the idx of number then do swap
				int idxNumber;
				int min = 7;
				for (int i = p + 1; i < job.size(); i++)
				{
					if (job[i] <= min && job[i] > job[p])
					{
						idxNumber = i;
						min = job[idxNumber]; 
					}	
				}
				int temp = job[p];
				job[p] = job[idxNumber];
				job[idxNumber] = temp;
				/*
				cout << "idxNumber = " << idxNumber << endl;
				cout << "After swap: " << endl;
				for (int i = 0; i < job.size(); i++)
				{
					cout << job[i] << " ";
				}
				cout << endl;
				*/

				//do reverse
				reverseArray(job, p + 1, job.size() - 1);
				/*
				cout << "After reverse: " << endl;
				for (int i = 0; i < job.size(); i++)
				{
					cout << job[i] << " ";
				}
				cout << endl;
				*/
			}
			
			//write output
			for (int i = 0; i < bestJob.size(); i++)
			{
				output << bestJob[i] + 1 << setw(2);
			}
			output << setw(5) << minCost << endl;
					
		}
		cout << "²Ä" << t + 1 << "­Ó"<< PATNUM << "µ§pattern" << endl;
		system("pause");
	}
}