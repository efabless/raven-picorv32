#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#include <stdlib.h>
#include <stdio.h>
#include <sys/select.h>


int set_interface_attribs (int fd, int speed, int parity)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                printf("error %d from tcgetattr", errno);
                return -1;
        }

        cfsetospeed (&tty, speed);
        cfsetispeed (&tty, speed);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
        {
                printf("error %d from tcsetattr", errno);
                return -1;
        }
        return 0;
}

void set_blocking (int fd, int should_block)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                printf("error %d from tggetattr", errno);
                return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
                printf("error %d setting term attributes", errno);
}

struct termios orig_termios;

void reset_terminal_mode()
{
    tcsetattr(0, TCSANOW, &orig_termios);
}

void set_conio_terminal_mode()
{
    struct termios new_termios;

    /* take two copies - one for now, one for later */
    tcgetattr(0, &orig_termios);
    memcpy(&new_termios, &orig_termios, sizeof(new_termios));

    /* register cleanup handler, and set the new terminal mode */
    atexit(reset_terminal_mode);
    cfmakeraw(&new_termios);
    tcsetattr(0, TCSANOW, &new_termios);
}

int kbhit()
{
    struct timeval tv = { 0L, 0L };
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, NULL, NULL, &tv);
}

char getch()
{
    int r;
    unsigned char c;
    if ((r = read(0, &c, sizeof(c))) < 0) {
        return r;
    } else {
        return c;
    }
}

int main()
{

    char *portname = "/dev/ttyUSB1";
    unsigned char buf[80], data, last_data;
    char c = ' ';
    int n, i;
    int fd = 0;
    unsigned char len1, len2, len3;
    unsigned int length;
    FILE *fptr;
    int is_header;

    set_conio_terminal_mode();

    fd = open (portname, O_RDWR | O_NOCTTY | O_SYNC);

    if (fd < 0)
    {
            printf("error %d opening %s: %s", errno, portname, strerror (errno));
            return 1;
    }

    set_interface_attribs (fd, B9600, 0);  // set speed to 115,200 bps, 8n1 (no parity)
    set_blocking (fd, 0);                // set no blocking


    do {
        while (!kbhit()) {
            if (n = read(fd, buf, sizeof(buf) - 1))
            {
                buf[n] = '\0';
                i = 0;
                while (buf[i] != '\0')
                {
                    if (buf[i] == '\n')
                        putchar('\r');
                    putchar(buf[i++]);
                }
            }
        }
        c = getch();
        n = write(fd, &c, 1);
        if (c == '7') {
            if ((fptr = fopen("photo.jpg", "wb+")) == NULL) {
                printf("Error opening file\n");
                exit(1);
            }
            read(fd, &len1, sizeof(len1));
            read(fd, &len2, sizeof(len2));
            read(fd, &len3, sizeof(len3));
            printf("0x%02x 0x%02x 0x%02x\n\r", len1, len2, len3);
            length = ((len3 << 16) | (len2 << 8) | len1) & 0x07fffff;
            printf("Length = 0x%06x\n\r", length);
            read(fd, &data, sizeof(data));
            if (data != 0xff) {
                printf("Error transferring data - data = 0x%02x\n\r", data);
                while (read(fd, buf, sizeof(buf))) {};
            }
            i = length;
            is_header = 0;
            read(fd, &data, sizeof(data));
            i--;
            while(i--) {
                last_data = data;
                while (read(fd, &data, sizeof(data)) == 0) {};
                data &= 0xff;
                if (is_header)
                    fwrite(&data, sizeof(data),1,fptr);
                else if ((data == 0xd8) && (last_data == 0xff)) {
                    is_header = 1;
                    fwrite(&last_data, sizeof(last_data),1,fptr);
                    fwrite(&data, sizeof(data),1,fptr);
                }
                if ((i & 0xff) == 0)
                    printf("Bytes remaining = 0x%06x\n\r", i);
                if ((data == 0xd9) && (last_data == 0xff))
                        break;
            }
            fclose(fptr);
            printf("File written successfully.\n\r");
        } else if (c == 'v') {
            system("eog photo.jpg");
        }
    } while (c != 'q');

}