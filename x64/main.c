#include <stdio.h>
#include <stdlib.h>


void xpandbmp24(unsigned char *img,unsigned int scale_num,unsigned int scale_den, unsigned char *buffer);/*The C declaration of an assembly routine*/


//###########################MAIN###############################################################
int main ( int argc , char ** argv )
{
    FILE * in , * out ;
    unsigned char * buffer ;
    unsigned char * img ;
    unsigned int len , scale_num, scale_den ;
    double scalef;
    int width, hight,size;
    int i ;

    if ( argc != 5 )
    {
        fprintf ( stderr , "Usage: %s <in_path> <out_path> <scale_num> <scale_den>\n" , argv [ 0 ] ) ;
        return ( 1 ) ;
    }
    sscanf ( argv [ 3 ] , "%d" , &scale_num ) ;
    sscanf ( argv [ 4 ] , "%d" , &scale_den ) ;
    if ( scale_num/(double) scale_den < 1 )
    {
        fprintf ( stderr , "Wrong scaling factor: %s\n" , argv [ 3 ] ) ;
        return ( 2 ) ;
    }
    in = fopen ( argv [ 1 ] , "rb" ) ;
    if ( in == NULL )
    {
        fprintf ( stderr , "Couldn't open input file: %s\n" , argv [ 1 ] ) ;
        return ( 3 ) ;
    }
    out = fopen ( argv [ 2 ] , "wb" ) ;
    if ( out == NULL )
    {
        fprintf ( stderr , "Couldn't open output file: %s\n" , argv [ 2 ] ) ;
        return ( 4 ) ;
    }

    fseek ( in , 0 , SEEK_END ) ;             /* move file pointer to end of file */
    len = ftell ( in ) ;                      /* get offset from beginning of the file */
    fseek ( in , 0 , SEEK_SET ) ;             /* move to the beginning of file */
    scalef = scale_num/(double)scale_den;
    img = ( unsigned char * ) malloc ( sizeof ( unsigned char ) * len);
    if ( img == NULL )
    {
        fprintf ( stderr , "Couldn't allocate memory, aborting\n" ) ;
        fclose ( in ) ;
        fclose ( out ) ;
        return ( 5 ) ;
    }
    fread ( img , len , 1 , in ) ;
    fclose ( in ) ;
    width =*(unsigned  int * )( & img [18] );
    width = (int)(scalef*width);
    hight =*(unsigned  int * )( & img [22] );
    hight = (int)(scalef*hight);
    size = ((width * 3 + 3) & ~3)* hight + 54;
    buffer = ( unsigned char * ) malloc (size);
    if ( img == NULL )
    {
        fprintf ( stderr , "Couldn't allocate memory, aborting\n" ) ;
        fclose ( out ) ;
        return ( 5 ) ;
    }
    for (i=0;i<54;i++) buffer[i]=img[i];
    *((unsigned int *)&buffer[2])   =   size;
    *((unsigned int *)&buffer[22])  =   hight;
    *((unsigned int *)&buffer[18])  =   width;

    printf ( "Enlarging please wait... " ) ;
    xpandbmp24(img, scale_num, scale_den, buffer ) ;
    printf ( "done. \nWriting date into file ..." ) ;
    fwrite ( buffer , size, 1 , out ) ;
    fclose ( out ) ;
    printf ( "done. \n");
    free ( buffer ) ;
    free ( img );
    return ( 0 ) ;
}


