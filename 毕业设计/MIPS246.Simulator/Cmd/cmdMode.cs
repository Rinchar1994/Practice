using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MIPS246.Core.Assembler;
using MIPS246.Core.DataStructure;
using MipsSimulator.Assembler;
using MipsSimulator.Devices;
using MipsSimulator.Tools;
using System.IO;

namespace MipsSimulator.Cmd
{
    class cmdMode
    {
        MIPS246.Core.Assembler.Assembler assembler = new MIPS246.Core.Assembler.Assembler();
        public static Hashtable lineTable;
        public static string outPath="";

        /* JLC DELETE public void start(string inputPath, string outputPath)
        {
            outPath=outputPath;
            MipsSimulator.Devices.Register.ResInitialize();
            MipsSimulator.Devices.Memory.MemInitialize();
            RunTimeCode.CodeTInitial();
            if (doAssembler(inputPath, outputPath,true))
            {
                if (File.Exists(outputPath))
                {
                    File.Delete(outputPath);
                }

                MipsSimulator.Monocycle.mMasterSwitch.Initialize();
                //判断是否要继续
                while (true)
                {
                    if (!MipsSimulator.Monocycle.mMasterSwitch.IFRun())
                    {
                        break;
                    }
                    else
                    {
                        string strArg1 = MipsSimulator.Devices.Register.GetRegisterValue("pc");
                        string pcstr = "pc = " + strArg1.Substring(2)+ "\r\n";
                        try
                        {
                            mIFStage.Start();
                            mDEStage.Start();
                            mEXEStage.Start();
                            mMEMStage.Start();
                            mWBStage.Start();
                        }
                        catch (Exception e)
                        {
                            MipsSimulator.Tools.FileControl.WriteFile(outputPath, e.Message);
                            return;
                        }
                       
                        int PC = (Int32)CommonTool.StrToNum(TypeCode.Int32, strArg1, 16);
                        //获取指令
                        Code code = RunTimeCode.GetCode(PC);
                        string codeStr = code.machineCode;
                        Int32 tmp = (Int32)CommonTool.StrToNum(TypeCode.Int32, codeStr, 2);
                        codeStr = tmp.ToString("X8");
                        for (int i = 0; i <= 31; i++)
                        {
                            string registerName = "$" + i;
                            string value = MipsSimulator.Devices.Register.GetRegisterValue(registerName);
                            value = "regfiles" + i + " = " + value.Substring(2)+ "\r\n";
                            value = value.ToLower();
                            MipsSimulator.Tools.FileControl.WriteFile(outputPath, value);
                        }
                        string instr = "instr = " + codeStr + "\r\n";
                        instr = instr.ToLower();
                        pcstr = pcstr.ToLower();
                        MipsSimulator.Tools.FileControl.WriteFile(outputPath, instr);
                        MipsSimulator.Tools.FileControl.WriteFile(outputPath, pcstr);
                    }
                }
            }
        }*/
        public static void addMessage(string message)
        {
            MipsSimulator.Tools.FileControl.WriteFile(outPath, message);            
        }
        public bool doAssembler(string inputPath, string outputPath,bool reset)
        {
            assembler = new MIPS246.Core.Assembler.Assembler(inputPath, outputPath);
            if (reset)
            {
                Form1.Reset();
            }
            else
            {
                RunTimeCode.Clear();
            }
            if (assembler.DoAssemble() == true)
            {
                List<String> sourceList = assembler.RawSource;
                lineTable = assembler.Linetable;
                List<Instruction> codeList = assembler.CodeList;

                if (MipsSimulator.Program.mode != 1)
                {
                    RunTimeCode.CodeTInitial();
                }
                for (int i = 0; i < codeList.Count; i++)
                {
                    
                    
                    CodeType codeType = convertToCodeType(codeList[i].Mnemonic.ToString());
                    string machineCode = convertToMachineCode(codeList[i].Machine_Code);
                    //JLC modify for monitor code begin
                    if(machineCode.Substring(0, 8) == "00001000" || machineCode.Substring(0, 8) == "00001100")
                    {
                        Int32 value = (Int32)CommonTool.StrToNum(TypeCode.Int32, machineCode, 2);
                        value += 512;
                        machineCode = (string)CommonTool.decToBin(value, 32);    
                    }
                    
                    //JLC end

                    int p = (int)lineTable[i];
                    string codeStr = sourceList[p];
                   
                    Code code = new Assembler.Code(codeType, null, codeStr, machineCode);
                    code.index = i;
                    //code.address = codeList[i].Address;
                    //addr of code be tested 
                    code.address = codeList[i].Address + 2048;
                    RunTimeCode.codeList.Add(code);
                }
                //JLC modify for report.txt output begin
                StreamWriter machinecode_report = new StreamWriter(outputPath, true);
                //JLC end
                for (int i = 0; i < sourceList.Count; i++)
                {
                    string codeStr = sourceList[i];
                   
                    string machineCode = "";
                    int j = 0;
                    for (j = 0; j < lineTable.Count; j++)
                    {
                        if ((int)lineTable[j] == i)
                        {
                            break;
                        }
                    }
                    if (j != lineTable.Count)
                    {
                        machineCode = RunTimeCode.codeList[j].machineCode;
                        Int32 tmp = (Int32)CommonTool.StrToNum(TypeCode.Int32, machineCode, 2);
                        //JLC ADD
                        string machinecode_split = tmp.ToString("X8") + " ";
                        for (int pos = 6; pos > 1; pos-- )
                        {
                            machinecode_split = machinecode_split.Insert(pos, " ");
                            pos--;
                        }
                        machinecode_report.Write(machinecode_split);
                        //JLC ADD END
                        machineCode = "0x" + tmp.ToString("X8");
                        Code code = new Assembler.Code(RunTimeCode.codeList[j].codeType, null, codeStr, machineCode);
                        code.index = i;
                        //JLC begin
                        //code.address = codeList[j].Address;
                        code.address = RunTimeCode.codeList[j].address;
                        //JLC end
                        RunTimeCode.Add(code);
                    }
                    else
                    {
                        Code code = new Assembler.Code(CodeType.NOP, null, codeStr, machineCode);
                        code.index = i;
                        code.address =-1;
                        RunTimeCode.Add(code);
                    }
                    
                }
                //JLC return to monitor code begin
                Code code_end = new Assembler.Code(CodeType.J, null, "return to the very begin", "0x08000000");
                code_end.index = sourceList.Count + 1;
                code_end.address = RunTimeCode.codeList[codeList.Count-1].address + 4;
                RunTimeCode.Add(code_end);
                code_end.machineCode = "0x00000000";
                code_end.index += 1;
                code_end.address += 4;
                code_end.codeType = CodeType.SLL;
                RunTimeCode.Add(code_end);
                //JLC end
                //JLC begin
                machinecode_report.Write("08 00 00 00 00 00 00 00");
                machinecode_report.Close();
                //JLC end


            }
            else
            {
                MipsSimulator.Tools.FileControl.WriteFile(outputPath, assembler.Error.ToString());
                return false;
            }
            return true;
        }
        private CodeType convertToCodeType(string mnemonic)
        {
            switch (mnemonic)
            {
                case "ADD":
                    return CodeType.ADD;
                case "ADDU":
                    return CodeType.ADDU;
                case "SUB":
                    return CodeType.SUB;
                case "SUBU":
                    return CodeType.SUBU;
                case "AND":
                    return CodeType.AND;
                case "OR":
                    return CodeType.OR;
                case "XOR":
                    return CodeType.XOR;
                case "NOR":
                    return CodeType.NOR;
                case "SLT":
                    return CodeType.SLT;
                case "SLTU":
                    return CodeType.SLTU;
                case "SLL":
                    return CodeType.SLL;
                case "SRL":
                    return CodeType.SRL;
                case "SRA":
                    return CodeType.SRA;
                case "SLLV":
                    return CodeType.SLLV;
                case "SRLV":
                    return CodeType.SRLV;
                case "SRAV":
                    return CodeType.SRAV;
                case "JR":
                    return CodeType.JR;
                case "ADDI":
                    return CodeType.ADDI;
                case "ADDIU":
                    return CodeType.ADDIU;
                case "ANDI":
                    return CodeType.ANDI;
                case "ORI":
                    return CodeType.ORI;
                case "XORI":
                    return CodeType.XORI;
                case "LUI":
                    return CodeType.LUI;
                case "LW":
                    return CodeType.LW;
                case "SW":
                    return CodeType.SW;
                case "BEQ":
                    return CodeType.BEQ;
                case "BNE":
                    return CodeType.BNE;
                case "SLTI":
                    return CodeType.SLTI;
                case "SLTIU":
                    return CodeType.SLTIU;
                case "J":
                    return CodeType.J;
                case "JAL":
                    return CodeType.JAL;
                default:
                    return CodeType.UNSUPPOTED;
            }
        }

        private string convertToMachineCode(BitArray Machine_Code)
        {
            string machineCode = "";
            bool[] boolArray = new bool[32];
            Machine_Code.CopyTo(boolArray, 0);
            for (int j = 0; j < 32; j++)
            {
                if (boolArray[j] == true)
                {
                    machineCode += "1";
                }
                else
                {
                    machineCode += "0";
                }
            }
            return machineCode;
        }
    }
}
