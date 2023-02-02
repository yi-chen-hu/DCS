#include <iostream>
#include <vector>
#include <bitset>
#include <iomanip>
#include <string>

#define PAT_NUM 500

using namespace std;

void generatePattern(vector<bitset<32>>&, int&);

int main()
{
	srand(88);

	vector<bitset<32>> reg;
	reg.clear();
	reg.resize(6);

	for (int i = 0; i < PAT_NUM; i++)
		generatePattern(reg, i);

	return 0;
}

void generatePattern(vector<bitset<32>>& reg, int& i)
{
	string Opcode_str;
	string Rs_str;
	string Rt_str;
	string Rd_str;
	bitset<5> shamt;
	string Funct_str;
	bitset<16> imm;

	//generate Opcode
	int Opcode = rand() % 2;
	switch (Opcode)
	{
	case 0:
		Opcode_str = "000000";
		break;
	case 1:
		Opcode_str = "001000";
		break;
	}


	if (Opcode == 0)
	{
		//generate Rs
		int Rs = rand() % 6;
		bitset<32> Rs_value;
		switch (Rs)
		{
		case 0:
			Rs_str = "10001";
			Rs_value = reg[0];
			break;
		case 1:
			Rs_str = "10010";
			Rs_value = reg[1];
			break;
		case 2:
			Rs_str = "01000";
			Rs_value = reg[2];
			break;
		case 3:
			Rs_str = "10111";
			Rs_value = reg[3];
			break;
		case 4:
			Rs_str = "11111";
			Rs_value = reg[4];
			break;
		case 5:
			Rs_str = "10000";
			Rs_value = reg[5];
			break;
		}

		//generate Rt
		int Rt = rand() % 6;
		bitset<32> Rt_value;
		switch (Rt)
		{
		case 0:
			Rt_str = "10001";
			Rt_value = reg[0];
			break;
		case 1:
			Rt_str = "10010";
			Rt_value = reg[1];
			break;
		case 2:
			Rt_str = "01000";
			Rt_value = reg[2];
			break;
		case 3:
			Rt_str = "10111";
			Rt_value = reg[3];;
			break;
		case 4:
			Rt_str = "11111";
			Rt_value = reg[4];
			break;
		case 5:
			Rt_str = "10000";
			Rt_value = reg[5];
			break;
		}

		//generate Rd
		int Rd = rand() % 6;
		switch (Rd)
		{
		case 0:
			Rd_str = "10001";
			break;
		case 1:
			Rd_str = "10010";
			break;
		case 2:
			Rd_str = "01000";
			break;
		case 3:
			Rd_str = "10111";
			break;
		case 4:
			Rd_str = "11111";
			break;
		case 5:
			Rd_str = "10000";
			break;
		}

		//generate Shamt
		int Shamt = rand() % 32;
		shamt = Shamt;

		//generate Funct
		int Funct = rand() % 6;
		switch (Funct)
		{
		case 0:
			Funct_str = "100000";
			reg[Rd] = bitset<32>(Rs_value.to_ulong() + Rt_value.to_ulong());
			break;
		case 1:
			Funct_str = "100100";
			reg[Rd] = Rs_value & Rt_value;
			break;
		case 2:
			Funct_str = "100101";
			reg[Rd] = Rs_value | Rt_value;
			break;
		case 3:
			Funct_str = "100111";
			reg[Rd] = ~(Rs_value | Rt_value);
			break;
		case 4:
			Funct_str = "000000";
			reg[Rd] = Rt_value << Shamt;
			break;
		case 5:
			Funct_str = "000010";
			reg[Rd] = Rt_value >> Shamt;
			break;
		}
	}
	else if (Opcode == 1)
	{
		//generate Rs
		int Rs = rand() % 6;
		bitset<32> Rs_value;
		switch (Rs)
		{
		case 0:
			Rs_str = "10001";
			Rs_value = reg[0];
			break;
		case 1:
			Rs_str = "10010";
			Rs_value = reg[1];
			break;
		case 2:
			Rs_str = "01000";
			Rs_value = reg[2];
			break;
		case 3:
			Rs_str = "10111";
			Rs_value = reg[3];
			break;
		case 4:
			Rs_str = "11111";
			Rs_value = reg[4];
			break;
		case 5:
			Rs_str = "10000";
			Rs_value = reg[5];
			break;
		}

		//generate Rt
		int Rt = rand() % 6;
		switch (Rt)
		{
		case 0:
			Rt_str = "10001";
			break;
		case 1:
			Rt_str = "10010";
			break;
		case 2:
			Rt_str = "01000";
			break;
		case 3:
			Rt_str = "10111";
			break;
		case 4:
			Rt_str = "11111";
			break;
		case 5:
			Rt_str = "10000";
			break;
		}

		//generate Imm
		int Imm = rand() % 65536;
		imm = Imm;
		reg[Rt] = bitset<32>(Rs_value.to_ulong() + imm.to_ulong());
	}//end of Instruction of pattern 1

	//output_reg here
	//save int value in range of 0 ~ 5 which represents 6 address seperately
	vector<int> output_reg;
	output_reg.clear();
	output_reg.resize(4);

	//save string output_reg
	string output_reg_str;

	//golden answer
	unsigned long out_1, out_2, out_3, out_4;

	//generate output_reg
	for (int j = 0; j < output_reg.size(); j++)
		output_reg[j] = rand() % 6;

	switch (output_reg[0])
	{
	case 0:
		output_reg_str += "10001";
		out_4 = reg[0].to_ulong();
		break;
	case 1:
		output_reg_str += "10010";
		out_4 = reg[1].to_ulong();
		break;
	case 2:
		output_reg_str += "01000";
		out_4 = reg[2].to_ulong();
		break;
	case 3:
		output_reg_str += "10111";
		out_4 = reg[3].to_ulong();
		break;
	case 4:
		output_reg_str += "11111";
		out_4 = reg[4].to_ulong();
		break;
	case 5:
		output_reg_str += "10000";
		out_4 = reg[5].to_ulong();
		break;
	}
	switch (output_reg[1])
	{
	case 0:
		output_reg_str += "10001";
		out_3 = reg[0].to_ulong();
		break;
	case 1:
		output_reg_str += "10010";
		out_3 = reg[1].to_ulong();
		break;
	case 2:
		output_reg_str += "01000";
		out_3 = reg[2].to_ulong();
		break;
	case 3:
		output_reg_str += "10111";
		out_3 = reg[3].to_ulong();
		break;
	case 4:
		output_reg_str += "11111";
		out_3 = reg[4].to_ulong();
		break;
	case 5:
		output_reg_str += "10000";
		out_3 = reg[5].to_ulong();
		break;
	}
	switch (output_reg[2])
	{
	case 0:
		output_reg_str += "10001";
		out_2 = reg[0].to_ulong();
		break;
	case 1:
		output_reg_str += "10010";
		out_2 = reg[1].to_ulong();
		break;
	case 2:
		output_reg_str += "01000";
		out_2 = reg[2].to_ulong();
		break;
	case 3:
		output_reg_str += "10111";
		out_2 = reg[3].to_ulong();
		break;
	case 4:
		output_reg_str += "11111";
		out_2 = reg[4].to_ulong();
		break;
	case 5:
		output_reg_str += "10000";
		out_2 = reg[5].to_ulong();
		break;
	}
	switch (output_reg[3])
	{
	case 0:
		output_reg_str += "10001";
		out_1 = reg[0].to_ulong();
		break;
	case 1:
		output_reg_str += "10010";
		out_1 = reg[1].to_ulong();
		break;
	case 2:
		output_reg_str += "01000";
		out_1 = reg[2].to_ulong();
		break;
	case 3:
		output_reg_str += "10111";
		out_1 = reg[3].to_ulong();
		break;
	case 4:
		output_reg_str += "11111";
		out_1 = reg[4].to_ulong();
		break;
	case 5:
		output_reg_str += "10000";
		out_1 = reg[5].to_ulong();
		break;
	}//end of output_reg of pattern 1

	//print input
	
	if (Opcode == 0)
		cout << Opcode_str << Rs_str << Rt_str << Rd_str << shamt << Funct_str << " " << output_reg_str << endl;

	else if (Opcode == 1)
		cout << Opcode_str << Rs_str << Rt_str << imm << " " << output_reg_str << endl;
	
	//print golden answer
	//cout << "0" << setw(12) << out_1 << setw(12) << out_2 << setw(12) << out_3 << setw(12) << out_4 << endl;


	//2nd pattern
	if (i % 5 == 0)//Opcode fail
	{
		Opcode = rand() % 64;
		while (Opcode == 0 || Opcode == 8)
			Opcode = rand() % 64;
		cout << bitset<6>(Opcode) << "10001" << "10001" << "10001" << "00001" << "100000";
	}
	else if (i % 5 == 1)//Rs fail
	{
		int Rs = rand() % 32;
		while (Rs == 17 || Rs == 18 || Rs == 8 || Rs == 23 || Rs == 31 || Rs == 16)
			Rs = rand() % 32;
		cout << "001000" << bitset<5>(Rs) << "10001" << "10001" << "00001" << "100000";
	}
	else if (i % 5 == 2)//Rt fail
	{
		int Rt = rand() % 32;
		while (Rt == 17 || Rt == 18 || Rt == 8 || Rt == 23 || Rt == 31 || Rt == 16)
			Rt = rand() % 32;
		cout << "000000" << "10001" << bitset<5>(Rt) << "10001" << "00001" << "100000";
	}
	else if (i % 5 == 3)//Rd fail
	{
		int Rd = rand() % 32;
		while (Rd == 17 || Rd == 18 || Rd == 8 || Rd == 23 || Rd == 31 || Rd == 16)
			Rd = rand() % 32;
		cout << "000000" << "10001" << "10001" << bitset<5>(Rd) << "00001" << "100000";
	}
	else if (i % 5 == 4)//Funct fail
	{
		int Funct = rand() % 64;
		while (Funct == 32 || Funct == 36 || Funct == 37 || Funct == 39 || Funct == 0 || Funct == 2)
			Funct = rand() % 64;
		cout << "000000" << "10001" << "10001" << "10001" << "00001" << bitset<6>(Funct);
	}//end of Instruction of pattern 2

	//print space bar to seperate Instruction and output_reg
	cout << " " << output_reg_str << endl;

	//print golden answer
	//cout << 1 << setw(12) << 0 << setw(12) << 0 << setw(12) << 0 << setw(12) << 0 << endl;
}

