#include "teaclib.h"

int limit, number, counter;
const string x, y = 3;
int i = 5;
bool result, isPrime;

int main(){

  counter = 0;
  number = 2;
  limit = readInt();

  while(number <= limit){
    if(counter < number){
      counter = counter +1;
      writeInt(number);
    }
    number = limit +1;
  }
  writeInt(counter);
  return 0;
}