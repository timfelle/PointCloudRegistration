// ============================================================================
// INCLUDES

#include <iostream>

#include "plyloader.h"

using namespace std;

// ============================================================================
// MAIN FUNCTION
int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input and help.
	if (argc == 1){
		printf(
		"INSERT HELP TEXT HERE \n");
		return EXIT_SUCCESS;
	}
	char *dataName = argv[1];
	cout << dataName << endl;
	return EXIT_SUCCESS;
}
