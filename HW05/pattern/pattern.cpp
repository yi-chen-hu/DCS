#include <iostream>
#include <iomanip>
#include <fstream>
#include <random>
#include <vector>

using namespace std;

#define PATNUM 1000

int main()
{
	srand(88);
	vector<int> filter_1, filter_2;
	vector<vector<int>> image;
	vector<vector<int>> conv_1, conv_2;

	filter_1.clear();
	filter_2.clear();
	image.clear();
	conv_1.clear();
	conv_2.clear();

	filter_1.resize(5);
	filter_2.resize(5);
	image.resize(8);
	conv_1.resize(8);
	conv_2.resize(4);

	for (int i = 0; i < image.size(); i++)
	{
		image[i].clear();
		image[i].resize(8);
	}

	for (int i = 0; i < conv_1.size(); i++)
	{
		conv_1[i].clear();
		conv_1[i].resize(8);
	}

	for (int i = 0; i < conv_2.size(); i++)
	{
		conv_2[i].clear();
		conv_2[i].resize(4);
	}

	ofstream input;
	input.open("input_1.txt");

	ofstream output;
	output.open("output_1.txt");

	input << PATNUM << endl;
	for (int i = 0; i < PATNUM; i++)
	{
		for (int j = 0; j < filter_1.size(); j++)
		{
			filter_1[j] = rand() % 16 - 8;
		}
		for (int j = 0; j < filter_1.size(); j++)
		{
			filter_2[j] = rand() % 16 - 8;
		}
		for (int j = 0; j < image.size(); j++)
		{
			for (int k = 0; k < 8; k++)
			{
				image[j][k] = rand() % 16 - 8;
			}
		}
		for (int j = 0; j < conv_1.size(); j++)
		{
			for (int k = 0; k < 4; k++)
			{
				conv_1[j][k] = image[j][k] * filter_1[0] + image[j][k + 1] * filter_1[1] + image[j][k + 2] * filter_1[2] + image[j][k + 3] * filter_1[3] + image[j][k + 4] * filter_1[4];
			}
		}
		for (int j = 0; j < conv_2.size(); j++)
		{
			for (int k = 0; k < 4; k++)
			{
				conv_2[j][k] = conv_1[j][k] * filter_2[0] + conv_1[j + 1][k] * filter_2[1] + conv_1[j + 2][k] * filter_2[2] + conv_1[j + 3][k] * filter_2[3] + conv_1[j + 4][k] * filter_2[4];
			}
		}


		//write input
		for (int j = 0; j < filter_1.size(); j++)
		{
			input << setw(3) << filter_1[j];
		}
		input << endl;
		for (int j = 0; j < filter_2.size(); j++)
		{
			input << setw(3) << filter_2[j] << endl;
		}
		for (int j = 0; j < image.size(); j++)
		{
			for (int k = 0; k < 8; k++)
			{
				input << setw(3) << image[j][k];
			}
			input << endl;
		}

		//write output
		for (int j = 0; j < conv_2.size(); j++)
		{
			for (int k = 0; k < 4; k++)
			{
				output << setw(7) << conv_2[j][k];
			}
			output << endl;
		}
		output << endl;
	}
	return 0;
}