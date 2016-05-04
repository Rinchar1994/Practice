using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MipsSimulator.Devices;
using MipsSimulator.Assembler;
using MipsSimulator.Tools;
using MipsSimulator.Cmd;
using System.Runtime.InteropServices;
using MipsSimulator.SerialPortFunc;
using System.IO.Ports;
using System.Text.RegularExpressions;


namespace MipsSimulator
{
    public partial class Form1 : Form
    {
        static public bool isStep = false;
        static public bool isStep2 = false;
        static public List<Int32> breakpoints = new List<int>();
        //JLC ADD 
        static public int breakpoints_old = -1;
        //JLC ADD END
        static public bool isBreak = false;

        static private int indexFinal = -1;
        static private int colorFinal = -1;

        static public string outputName = "";
        public SerialPortFunc.SerialPortFunc serialport = new SerialPortFunc.SerialPortFunc();

        public Form1()
        {
            InitializeComponent();

            this.txtContent.MouseWheel += new MouseEventHandler(txtContect_MouseWheel);

            textBox2.Font = new Font(textBox2.Font.FontFamily, 15, textBox2.Font.Style);

            //寄存器表格
            Register.ResInitialize();
            this.dataGridView2.DataSource = Register.Res;
            this.dataGridView2.Columns[0].FillWeight = 30;
            this.dataGridView2.Columns[1].FillWeight = 70;
            this.dataGridView2.Columns[0].ReadOnly = true;
            
            this.dataGridView2.Font = new Font("宋体", 10, FontStyle.Bold);
           // this.dataGridView2.ReadOnly = false;
            
          
            //内存表格
            /*JLC DELETE Memory.MemInitialize();
            this.dataGridView3.DataSource = Memory.Mem;
            this.dataGridView3.Columns[0].ReadOnly = true;
            //this.dataGridView3.ReadOnly= false;
            this.dataGridView3.Font = new Font("宋体", 10, FontStyle.Bold);*/
           
            //JLC ADD 初始化下拉串口名称列表框
            string[] ports = SerialPort.GetPortNames();
            Array.Sort(ports);
            COM_COMBO.Items.AddRange(ports);
            COM_COMBO.SelectedIndex = COM_COMBO.Items.Count > 0 ? 0 : -1;
            BAUDRATE_COMBO.Items.AddRange(new object[] {
                "2400",
                "4800",
                "9600",
                "19200",
                "38400",
                "57600",
                "115200"
            });
            BAUDRATE_COMBO.SelectedIndex = BAUDRATE_COMBO.Items.IndexOf("9600");
            serialport.comm.NewLine = "\r\n";
            serialport.comm.RtsEnable = true;
            

            //Execute表格
            RunTimeCode.CodeTInitial();
            this.dataGridView1.DataSource = RunTimeCode.CodeT;
            this.dataGridView1.Columns[0].FillWeight = 20;
            this.dataGridView1.Columns[1].FillWeight = 20;
            this.dataGridView1.Columns[2].FillWeight = 20;
            this.dataGridView1.Columns[3].FillWeight = 40;
            this.dataGridView1.Columns[1].ReadOnly = true;
            this.dataGridView1.Columns[2].ReadOnly = true;
            this.dataGridView1.Columns[3].ReadOnly = false;
            this.dataGridView1.Font = new Font("宋体", 10, FontStyle.Bold);
           // this.dataGridView1.ReadOnly = false;
            this.dataGridView1.CellValueChanged += new DataGridViewCellEventHandler(dataGridView1_CellValueChanged);
        }

        private int pageLine = 0;
        private void txtContect_TextChanged(object sender, EventArgs e)
        {
            //调用顺序不可变
            SetScrollBar();
            ShowRow();
            ShowCursorLine();
        }

        //鼠标滚动
        void txtContect_MouseWheel(object sender, MouseEventArgs e)
        {
            _timer1.Enabled = true;
        }

        // 上、下键
        private void txtContent_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData == System.Windows.Forms.Keys.Up || e.KeyData == System.Windows.Forms.Keys.Down)
                SetScrollBar();

        }
        private void txtContent_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyData == System.Windows.Forms.Keys.Up || e.KeyData == System.Windows.Forms.Keys.Down)
                ShowCursorLine();
        }

        //点击滚动条
        private void vScrollBar1_ValueChanged(object sender, EventArgs e)
        {
            int t = SetScrollPos(this.txtContent.Handle, 1, _vScrollBar1.Value, true);
            SendMessage(this.txtContent.Handle, WM_VSCROLL, SB_THUMBPOSITION + 0x10000 * _vScrollBar1.Value, 0);
            ShowRow();
        }

        //显示光标行
        private void txtContent_MouseDown(object sender, MouseEventArgs e)
        {
            ShowCursorLine();
        }

        //文本框大小改变
        private void txtContent_SizeChanged(object sender, EventArgs e)
        {
            SCROLLINFO si = new SCROLLINFO();
            si.cbSize = (uint)Marshal.SizeOf(si);
            si.fMask = SIF_ALL;
            int r = GetScrollInfo(this.txtContent.Handle, SB_VERT, ref si);
            pageLine = (int)si.nPage;
            _timer1.Enabled = true;
            ShowRow();
        }

        //行显示栏宽度自适应
        private void txtRow_TextChanged(object sender, EventArgs e)
        {
            if (this._txtRow.Lines.Length > 0)
            {
                System.Drawing.SizeF s = this._txtRow.CreateGraphics().MeasureString(this._txtRow.Lines[this._txtRow.Lines.Length - 1], this._txtRow.Font);
                this._txtRow.Width = (int)s.Width;
            }
        }

        private void txtRow_SizeChanged(object sender, EventArgs e)
        {
            this.txtContent.Location = new Point(this._txtRow.Width, this.txtContent.Location.Y);
            this.txtContent.Width = this.ClientSize.Width - this._txtRow.Width;
        }

        //private void menuItemAbout_Click(object sender, EventArgs e)
        //{
        //    About a = new About();
        //    a.ShowDialog();
        //}

        #region Method
        private void ShowCursorLine()
        {
            _toolStripStatusLabel1.Text = "line: " + (this.txtContent.GetLineFromCharIndex(this.txtContent.SelectionStart) + 1);
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            SetScrollBar();
            _timer1.Enabled = false;
        }

        private void SetScrollBar()
        {
            SCROLLINFO si = new SCROLLINFO();
            si.cbSize = (uint)Marshal.SizeOf(si);
            si.fMask = SIF_ALL;
            int r = GetScrollInfo(this.txtContent.Handle, SB_VERT, ref si);
            pageLine = (int)si.nPage;
            this._vScrollBar1.LargeChange = pageLine;

            if (si.nMax >= si.nPage)
            {
                this._vScrollBar1.Visible = true;
                this._vScrollBar1.Maximum = si.nMax;
                this._vScrollBar1.Value = si.nPos;
            }
            else
                this._vScrollBar1.Visible = false;
        }

        private void ShowRow()
        {
            int firstLine = txtContent.GetLineFromCharIndex(txtContent.GetCharIndexFromPosition(new Point(0, 2)));
            string[] lin = new string[pageLine];
            for (int i = 0; i < pageLine; i++)
            {
                lin[i] = (i + firstLine + 1).ToString();
            }
            _txtRow.Lines = lin;
        }

        #endregion

        #region API 调用

        public static uint SIF_RANGE = 0x0001;
        public static uint SIF_PAGE = 0x0002;
        public static uint SIF_POS = 0x0004;
        public static uint SIF_TRACKPOS = 0x0010;
        public static uint SIF_ALL = (SIF_RANGE | SIF_PAGE | SIF_POS | SIF_TRACKPOS);
        public int SB_THUMBPOSITION = 4;
        public int SB_VERT = 1;
        public int WM_VSCROLL = 0x0115;

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct SCROLLINFO
        {
            public uint cbSize;
            public uint fMask;
            public int nMin;
            public int nMax;
            public uint nPage;
            public int nPos;
            public int nTrackPos;
        }

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int GetScrollInfo(IntPtr hwnd, int bar, ref SCROLLINFO si);

        [DllImport("user32.dll")]
        private static extern int GetScrollPos(IntPtr hwnd, int nbar);

        [DllImport("user32.dll")]
        public static extern int SetScrollPos(IntPtr hWnd, int nBar, int nPos, bool Rush);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);

        #endregion

        private void registerEdit(object sender, DataGridViewCellEventArgs e)
        {
            int i = e.RowIndex;
            string value = (string)Register.Res.Rows[i]["Value"];
            if (!CommonTool.JudgeValue(value))
            {
                MessageBox.Show("修改错误！");
                Register.Res.Rows[i]["Value"] = "0x00000000";
                this.dataGridView2.DataSource = Register.Res;
                return;
            }
            this.dataGridView2.DataSource = Register.Res;
        }

        /*JLC DELETE private void memoryEdit(object sender, DataGridViewCellEventArgs e)
        {
            int i = e.RowIndex;
            int j = e.ColumnIndex;

            string value = (string)Memory.Mem.Rows[i][j];
            if (!CommonTool.JudgeValue(value))
            {
                MessageBox.Show("修改错误！");
               Memory.Mem.Rows[i][j] = "0x00000000";
               this.dataGridView3.DataSource = Memory.Mem;
                return;
            }
            this.dataGridView3.DataSource = Memory.Mem;
        }*/

        private void dataGridView1_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            int index = e.ColumnIndex;
            if (index != 3)
                return;
            string inputPath = System.Environment.CurrentDirectory;
            inputPath = inputPath + "\\source.txt";
            string outputPath = System.Environment.CurrentDirectory;
            outputPath = outputPath + "\\report.txt";
            if (File.Exists(inputPath))
            {
                File.Delete(inputPath);
            }
            if (File.Exists(outputPath))
            {
                File.Delete(outputPath);
            }

            string source = "";
            for (int i = 0; i < this.dataGridView1.Rows.Count; i++)
            {
                source = this.dataGridView1.Rows[i].Cells[3].Value.ToString()+"\r\n";
                MipsSimulator.Tools.FileControl.WriteFile(inputPath, source);
            }
            MipsSimulator.Cmd.cmdMode cmdMode = new Cmd.cmdMode();
            if (!cmdMode.doAssembler(inputPath, outputPath,false))
            {
                string error = MipsSimulator.Tools.FileControl.ReadFile(outputPath);
                RunTimeCode.Clear();
                textBox2.Text += error;
                this.tabControl3.SelectedTab = this.tabPage5;
                return;
            }
            dataGridView1.Refresh();
            codeColor(indexFinal, colorFinal);
            //JLC DELETE for (int i = 0; i < breakpoints.Count; i++)
            if(breakpoints.Count > 0)
            {
                int point = breakpoints[0];
                dataGridView1.Rows[point].Cells[0].Value = true;

            }
            
            this.tabControl1.SelectedTab = this.tabPage2;
            return;
        }
        private void frmMain_KeyDown(object sender, KeyEventArgs e)
        {
             switch (e.KeyCode) 
             {
                    case Keys.F1: 
                        toolStripButton1_Click_1(this, EventArgs.Empty); //assembler
                        break; 

                      case Keys.F2: 
                          toolStripButton4_Click(this, EventArgs.Empty); //running
                          break; 
                      case Keys.F3: 
                          toolStripButton5_Click(this, EventArgs.Empty); //step
                          break;
                     case Keys.F4: 
                        toolStripButton6_Click(this, EventArgs.Empty); //break
                        break;
                     case Keys.F5:
                        toolStripButton7_Click_1(this, EventArgs.Empty); //compare
                        break; 
             }
            if (e.KeyCode == Keys.S && e.Modifiers == Keys.Control)         //Ctrl+s
            {
                toolStripButton1_Click(this, EventArgs.Empty);
            }
            if (e.KeyCode == Keys.O && e.Modifiers == Keys.Control)         //Ctrl+o
            {
                openButton_Click(this, EventArgs.Empty);
            }
             if (e.KeyCode == Keys.R && e.Modifiers == Keys.Alt)         //alt+r
            {
                clearRegButton_Click(this, EventArgs.Empty);
            }
             if (e.KeyCode == Keys.M && e.Modifiers == Keys.Alt)         //alt+m
            {
                clearMemButton_Click(this, EventArgs.Empty);
            }
     
        }

        //File    Open
        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string stream = "";
            FileControl.Open(ref stream);
            this.txtContent.Text = stream;
        }

        //File    Save
        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            toolStripButton1_Click(sender, e);
        }

        //Help   About
        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            About aboutFrm = new About();
            aboutFrm.Visible = true;
        }

        //save
        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            string stream = this.txtContent.Text;
            if (stream.Length <= 0)
            {
                MessageBox.Show("请输入代码！");
                return;
            }
            FileControl.Save(stream);
        }

        //分析代码
        private void toolStripButton1_Click_1(object sender, EventArgs e)
        {
            textBox2.Text = "";
            if (this.txtContent.Text == null || this.txtContent.Text == "")
            {
                MessageBox.Show("代码不可以为空！");
                return;
            }
            string[] codes = this.txtContent.Text.Split(new string[1] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
            if (codes == null || codes.Length <= 0)
            {
                MessageBox.Show("代码不可以为空！");
                return;
            }

            Reset();
            RunTimeCode.Clear();
            string inputPath = System.Environment.CurrentDirectory;
            inputPath = inputPath + "\\source.txt";
            string outputPath = System.Environment.CurrentDirectory;
            outputPath = outputPath + "\\report.txt";
            if (File.Exists(inputPath))
            {
                File.Delete(inputPath);
            }
            if (File.Exists(outputPath))
            {
                File.Delete(outputPath);
            }
            MipsSimulator.Tools.FileControl.WriteFile(inputPath, this.txtContent.Text);

            MipsSimulator.Cmd.cmdMode cmdMode = new Cmd.cmdMode();
            if (!cmdMode.doAssembler(inputPath, outputPath,true))
            {
                string error = MipsSimulator.Tools.FileControl.ReadFile(outputPath);
                RunTimeCode.Clear();
                textBox2.Text += error;
                this.tabControl3.SelectedTab = this.tabPage5;
                return;
            }
            //JLC ADD
            string code_input = "01 ";
            code_input += File.ReadAllText(outputPath);
            if(serialport.comm.IsOpen)
            {
                serialport.Send(code_input);
            }
            //JLC ADD END

            dataGridView1.DataSource = RunTimeCode.CodeT;
            this.dataGridView2.DataSource = Register.Res;
            //this.dataGridView3.DataSource = Memory.Mem;
            this.tabControl1.SelectedTab = this.tabPage2;

        }

        static public void codeColor(int index, int color)
        {
           
            indexFinal = index;
            colorFinal = color;
            //this.colorChange(index, color);
            switch (color)
            {
                case 1:
                    {

                        MipsSimulator.Program.form1.dataGridView1.Rows[index].DefaultCellStyle.ForeColor = Color.Red;
                        if (MipsSimulator.Program.mode == 1)
                        {
                            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
                            {
                                if (i != index)
                                    MipsSimulator.Program.form1.dataGridView1.Rows[i].DefaultCellStyle.ForeColor = Color.Black;
                            }
                        }
                        break;
                    }
                case 2:
                    {
                        MipsSimulator.Program.form1.dataGridView1.Rows[index].DefaultCellStyle.ForeColor = Color.Orange;
                        if (MipsSimulator.Program.mode == 1)
                        {
                            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
                            {
                                if (i != index)
                                    MipsSimulator.Program.form1.dataGridView1.Rows[i].DefaultCellStyle.ForeColor = Color.Black;
                            }
                        }
                        break;
                    }
                case 3:
                    {
                        MipsSimulator.Program.form1.dataGridView1.Rows[index].DefaultCellStyle.ForeColor = Color.Green;
                        if (MipsSimulator.Program.mode == 1)
                        {
                            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
                            {
                                if (i != index)
                                    MipsSimulator.Program.form1.dataGridView1.Rows[i].DefaultCellStyle.ForeColor = Color.Black;
                            }
                        }
                        break;
                    }
                case 4:
                    {
                        MipsSimulator.Program.form1.dataGridView1.Rows[index].DefaultCellStyle.ForeColor = Color.Purple;
                        if (MipsSimulator.Program.mode == 1)
                        {
                            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
                            {
                                if (i != index)
                                    MipsSimulator.Program.form1.dataGridView1.Rows[i].DefaultCellStyle.ForeColor = Color.Black;
                            }
                        }
                        break;
                    }
                case 5:
                    {
                        MipsSimulator.Program.form1.dataGridView1.Rows[index].DefaultCellStyle.ForeColor = Color.Blue;
                        if (MipsSimulator.Program.mode == 1)
                        {
                            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
                            {
                                if (i != index)
                                    MipsSimulator.Program.form1.dataGridView1.Rows[i].DefaultCellStyle.ForeColor = Color.Black;
                            }
                        }
                        break;
                    }
            }
        }

        static public void Message(string message)
        {
            MipsSimulator.Program.form1.textBox2.Text += message + "\r\n";
        }

        //复位
        static public void Reset()
        {
            isStep = false;
            isStep2 = false;
            isBreak = false;
            breakpoints.Clear();
            //JLC ADD
            breakpoints_old = -1;
            //JLC ADD END

            Register.Clear();
            RunTimeCode.Clear();

            //MasterSwitch.Initialize();
            //MasterSwitch.Close();

            // IFStage.Close();
            //DEStage.Close();
            //EXEStage.Close();
            // MEMStage.Close();
            // WBStage.Close();

            /*JLC DELETE mMasterSwitch.Initialize();
            mMasterSwitch.Close();*/
        }

        //单周期running
        private void toolStripButton4_Click(object sender, EventArgs e)
        {
            /*JLC DELETE SaveFileDialog saveFD = new SaveFileDialog();
            saveFD.Filter = "文本文件(*.txt)|*.txt";
            saveFD.FilterIndex = 1;
            saveFD.AddExtension = true;
            saveFD.RestoreDirectory = true;

            if (saveFD.ShowDialog() == DialogResult.OK)
            {
                outputName = saveFD.FileName;
            }
            else
            {
                outputName = System.Environment.CurrentDirectory + "output.txt";
            }*/

            /* JLC DELETE mMasterSwitch.Start();*/
            //JLC ADD
            if(serialport.comm.IsOpen)
            {
                serialport.Send("05");
                while (serialport.comm.BytesToRead == 0) ;
                System.Threading.Thread.Sleep(500);
                string buf = serialport.Receive();
                Register.SetRegisterValue(buf);
                Form1.codeColor((int)cmdMode.lineTable[RunTimeCode.CodeIndex], 5);
            }
            //JLC ADD END
        }

        //单周期step
        private void toolStripButton5_Click(object sender, EventArgs e)
        {
            //JLC ADD
            if(serialport.comm.IsOpen)
            {
                serialport.Send("09");
                //延时100ms
                while (serialport.comm.BytesToRead == 0) ;
                System.Threading.Thread.Sleep(500);
                string buf = serialport.Receive();
                Register.SetRegisterValue(buf);
                Form1.codeColor((int)cmdMode.lineTable[RunTimeCode.CodeIndex], 5);
            }
            //JLC ADD END
            /*JLC DELETE if (!isStep2)
            {
                mMasterSwitch.Initialize();
            }
            isStep2 = true;
            mMasterSwitch.StepInto();*/
        }

        //
        static private void breaksCompute()
        {
            breakpoints.Clear();
            for (int i = 0; i < MipsSimulator.Program.form1.dataGridView1.Rows.Count; i++)
            {
                try
                {
                    //第0列是checkbox 
                    DataGridViewCheckBoxCell check = MipsSimulator.Program.form1.dataGridView1.Rows[i].Cells[0] as DataGridViewCheckBoxCell;
                    if ((bool)check.EditedFormattedValue == true)//先验证为null                    
                    {
                        string idStr = (string)MipsSimulator.Program.form1.dataGridView1.Rows[i].Cells[1].Value;
                      //  int id = Convert.ToInt32(dataGridView1.Rows[i].Cells[1].Value);
                        //int id =(Int32) CommonTool.StrToNum(TypeCode.Int32, idStr, 16);
                        //id = id / 4;
                        //if ((bool)check.Value)
                        if(idStr != "")
                        {
                            breakpoints.Add(i);
                        }
                    }
                }
                catch (Exception ex)
                {
                    Message(ex.Message.ToString());
                }
            }
        }

        //单周期断点
        private void toolStripButton6_Click(object sender, EventArgs e)
        {
            if(serialport.comm.IsOpen)
            {
                serialport.Send("08");
                //可能延时不够
                while (serialport.comm.BytesToRead == 0) ;
                System.Threading.Thread.Sleep(500);
                string buf = serialport.Receive();
                Register.SetRegisterValue(buf);
                Form1.codeColor((int)cmdMode.lineTable[RunTimeCode.CodeIndex], 5);
            }
            /*JLC DELETE if (!isBreak)
            {
                mMasterSwitch.Initialize();
            }
            isBreak = true;
            mMasterSwitch.BreakPoint();*/
        }

        private void toolStripButton7_Click(object sender, EventArgs e)
        {

        }

        private void toolStripButton8_Click(object sender, EventArgs e)
        {

        }

        private void toolStripButton9_Click(object sender, EventArgs e)
        {

        }

        private void toolStripButton10_Click(object sender, EventArgs e)
        {

        }

        private void toolStripButton11_Click(object sender, EventArgs e)
        {

        }

        private void tabControl3_SelectedIndexChanged(object sender, EventArgs e)
        {
            //this.dataGridView3.Refresh();
        }

        private void openButton_Click(object sender, EventArgs e)
        {
            string stream = "";
            FileControl.Open(ref stream);
            if (stream == null)
                return;
            this.txtContent.Text = stream;
        }

        private void clearRegButton_Click(object sender, EventArgs e)
        {
            Register.Clear();
        }

        private void clearMemButton_Click(object sender, EventArgs e)
        {
            Memory.clear();
        }
        static Form2 from2;
        private void toolStripButton7_Click_1(object sender, EventArgs e)
        {
            from2 = new Form2();
            from2.Visible = true;
        }
        
        public static string getOutput()
        {
            return outputName;

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void COM_COMBO_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void BITRATE_TextChanged(object sender, EventArgs e)
        {

        }

        //JLC ADD
        private void open_Click(object sender, EventArgs e)
        {
            if(serialport.comm.IsOpen)
            {
                serialport.comm.Close();
            }
            else
            {
                serialport.comm.PortName = COM_COMBO.Text;
                serialport.comm.BaudRate = int.Parse(BAUDRATE_COMBO.Text);
                try
                {
                    serialport.comm.Open();
                }
                catch(Exception ex)
                {
                    serialport.comm = new SerialPort();
                    MessageBox.Show(ex.Message);
                }
            }
            open.Text = serialport.comm.IsOpen ? "Close" : "Open";
        }
        //JLC ADD END

        private void BAUDRATE_COMBO_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void toolStripButton2_Click(object sender, EventArgs e)
        {
            if(serialport.comm.IsOpen)
            {
                serialport.Send("0a");
                while (serialport.comm.BytesToRead == 0) ;
                System.Threading.Thread.Sleep(500);
                string buf = serialport.Receive();
                Register.SetRegisterValue(buf);
                Form1.codeColor((int)cmdMode.lineTable[RunTimeCode.CodeIndex], 5);
            }
        }

        private void MEMADDR_BTN_Click(object sender, EventArgs e)
        {
            if(serialport.comm.IsOpen)
            {
                serialport.Send("04" + mem_addr.Text);
                while (serialport.comm.BytesToRead == 0) ;
                mem_value.Text = serialport.Receive().Replace(" ", "");
            }
        }

        private void toolStripButton3_Click(object sender, EventArgs e)
        {
            breaksCompute();
            //JLC ADD
            if (breakpoints.Count > 0)
            {
                int point = breakpoints[0];
                if (breakpoints_old != -1)
                {
                    if (serialport.comm.IsOpen)
                    {
                        serialport.Send("07");
                    }
                }
                if (serialport.comm.IsOpen)
                {
                    serialport.Send("06 " + dataGridView1.Rows[point].Cells[1].Value.ToString().Remove(0, 2));
                }
                breakpoints_old = breakpoints[0];
            }
            else
            {
                breakpoints_old = -1;
                if (serialport.comm.IsOpen)
                {
                    serialport.Send("07");
                }
            }
            //JLC ADD END
        }

    }
}
