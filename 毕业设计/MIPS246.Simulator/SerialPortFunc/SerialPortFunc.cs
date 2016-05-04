using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.IO.Ports;
using MipsSimulator.Tools;

namespace MipsSimulator.SerialPortFunc
{
    public class SerialPortFunc
    {
        public SerialPort comm = new SerialPort();
        public StringBuilder builder = new StringBuilder();

        public string Receive()
        {
            int n = comm.BytesToRead;
            byte[] buf = new byte[n];
            comm.Read(buf, 0, n); //serialport data is in buf
            builder = builder.Remove(0, builder.Length);
            foreach(byte b in buf)
            {
                builder.Append(b.ToString("X2") + " ");
            }
            return builder.ToString();
        }

        public void Send(string data)
        {
            data = data.Replace(" ", "");
            List<byte> buf = new List<byte>();
            string temp = "";
            while(data.Length > 0)
            {
                temp = data.Substring(0, 2);
                data = data.Remove(0, 2);
                buf.Add(Convert.ToByte(temp, 16));
            }
            comm.Write(buf.ToArray(), 0, buf.Count);
        }
    }
}
