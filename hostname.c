#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <mpi.h>

#define MAXLEN 16

main(int argc,  char *argv[]) {

    int count, totalcnt, proc_num, my_rank, my_name_length, i, flag;
    char my_name[MAXLEN], master_name[MAXLEN], recv_buffer[MAXLEN];
    char all_name[128][MAXLEN];
    MPI_Status status;
  
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &proc_num);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  
    MPI_Get_processor_name(my_name, &my_name_length);
  
    if (my_rank == 0) { 

        totalcnt = 0;
        strcpy(all_name[totalcnt++], my_name);
        for (count = 1; count < proc_num; count++) {
            MPI_Recv (recv_buffer, MAXLEN, MPI_CHAR, MPI_ANY_SOURCE, MPI_ANY_TAG,
                      MPI_COMM_WORLD, &status);

            flag = 0;
            for( i = 0; i < totalcnt; i++) {
                if(strcmp(all_name[i], recv_buffer) == 0) {
                    flag = 1;
                    break;
                }
            }

            if(flag == 0)
                strcpy(all_name[totalcnt++], recv_buffer);
                
        }

        for( i = 0; i < totalcnt; i++)
            printf("%s\n", all_name[i]);

    }
    else {
        MPI_Send (my_name, strlen(my_name) + 1, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }
  
    MPI_Finalize();
     
    exit(0);
}
