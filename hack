using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Threading;
using System.Security.Cryptography;
using System.Net;
using System.Runtime.InteropServices;
using System****;
using System.Media;
using System.Xml;

//Created by -[I]fLuX

namespace IfLuXInject
{
    class Inject
    {
        private static class WINAPI
        {
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern IntPtr OpenProcess(UInt32 dwDesiredAccess,Int32 bInheritHandle,UInt32 dwProcessId);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern Int32 CloseHandle(IntPtr hObject);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern IntPtr GetProcAddress(IntPtr hModule,string lpProcName);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern IntPtr GetModuleHandle(string lpModuleName);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern IntPtr VirtualAllocEx(IntPtr hProcess,IntPtr lpAddress,IntPtr dwSize,uint flAllocationType,uint flProtect);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern Int32 WriteProcessMemory(IntPtr hProcess,IntPtr lpBaseAddress,byte[] buffer,uint size,out IntPtr lpNumberOfBytesWritten);
            [DllImport("kernel32.dll", SetLastError = true)]
            public static extern IntPtr CreateRemoteThread(IntPtr hProcess,IntPtr lpThreadAttribute,IntPtr dwStackSize,IntPtr lpStartAddress,IntPtr lpParameter,uint dwCreationFlags,IntPtr lpThreadId);
            public static class VAE_Enums{
                public enum AllocationType{
                    MEM_COMMIT = 0x1000,
                    MEM_RESERVE = 0x2000,
                    MEM_RESET = 0x80000,}
                public enum ProtectionConstants{
                    PAGE_EXECUTE = 0X10,
                    PAGE_EXECUTE_READ = 0X20,
                    PAGE_EXECUTE_READWRITE = 0X04,
                    PAGE_EXECUTE_WRITECOPY = 0X08,
                    PAGE_NOACCESS = 0X01}}}
        public static bool DoInject(Process pToBeInjected,string sDllPath,out string sError){
            IntPtr hwnd = IntPtr.Zero;
            if (!CRT(pToBeInjected, sDllPath, out sError, out hwnd)){
                if (hwnd != (IntPtr)0)
                    WINAPI.CloseHandle(hwnd);
                return false;}
            int wee = Marshal.GetLastWin32Error();
            return true;}
        private static bool CRT(Process pToBeInjected,string sDllPath,out string sError,out IntPtr hwnd){
            sError = String.Empty;
            IntPtr hndProc = WINAPI.OpenProcess((0x2 | 0x8 | 0x10 | 0x20 | 0x400), 1,(uint)pToBeInjected.Id);
            hwnd = hndProc;
            if (hndProc == (IntPtr)0){
                sError = "Unable to attatch to process.\n";
                sError += "Error code: " + Marshal.GetLastWin32Error();
                return false;}
            IntPtr lpLLAddress = WINAPI.GetProcAddress(WINAPI.GetModuleHandle("kernel32.dll"),"LoadLibraryA");
            if (lpLLAddress == (IntPtr)0){
                sError = "Unable to find address of \"LoadLibraryA\".\n";
                sError += "Error code: " + Marshal.GetLastWin32Error();
                return false;}
            IntPtr lpAddress = WINAPI.VirtualAllocEx(hndProc,(IntPtr)null,(IntPtr)sDllPath.Length,(uint)WINAPI.VAE_Enums.AllocationType.MEM_COMMIT |(uint)WINAPI.VAE_Enums.AllocationType.MEM_RESERVE,(uint)WINAPI.VAE_Enums.ProtectionConstants.PAGE_EXECUTE_READWRITE);
            if (lpAddress == (IntPtr)0){
                if (lpAddress == (IntPtr)0){
                    sError = "Unable to allocate memory to target process.\n";
                    sError += "Error code: " + Marshal.GetLastWin32Error();
                    return false;}}
            byte[] bytes = CalcBytes(sDllPath);
            IntPtr ipTmp = IntPtr.Zero;
            WINAPI.WriteProcessMemory(hndProc, lpAddress, bytes, (uint)bytes.Length, out ipTmp);
            if (Marshal.GetLastWin32Error() != 0){
                sError = "Unable to write memory to process.";
                sError += "Error code: " + Marshal.GetLastWin32Error();
                return false;}
            IntPtr ipThread = WINAPI.CreateRemoteThread(hndProc,(IntPtr)null,(IntPtr)0,lpLLAddress,lpAddress,0,(IntPtr)null);
            if (ipThread == (IntPtr)0){
                sError = "Unable to load dll into memory.";
                sError += "Error code: " + Marshal.GetLastWin32Error();
                return false;}
            return true;}
        private static byte[] CalcBytes(string sToConvert){
            byte[] bRet = System.Text.Encoding.ASCII.GetBytes(sToConvert);
            return bRet;}}
    class DxInject
    {
        [DllImport("user32.dll")]
        public static extern ushort GetKeyState(short nVirtKey);
        public const ushort keyDownBit = 0x80;
        public static bool IsKeyPressed(Keys key){
            return ((GetKeyState((short)key) & keyDownBit) == keyDownBit);}
        static void InjectDll(){
            int ID = 0;
            Process proc;
            String error;
            bool bfound = false;
            string sProcess = "crossfire";
            string ProcName = Process.GetCurrentProcess().ProcessName;
            string exePath = Environment.CurrentDirectory + "\\" + ProcName;
            string DllPath = exePath + ".dll";
            if (!File.Exists(DllPath)){
                MessageBox.Show("Dll File Not Found!");
                System.Environment.Exit(1);}
            while (!bfound){
                if (IsKeyPressed(Keys.End)){
                    MessageBox.Show("Exiting Injection!");
                    System.Environment.Exit(1);}
                foreach (Process pro in Process.GetProcesses()){
                    if (pro.ProcessName == sProcess){
                        ID = pro.Id;
                        bfound = true;
                        break;}}
                Thread.Sleep(100);}
            proc = Process.GetProcessById(ID);
            bool result = Inject.DoInject(proc, DllPath, out error);
           if (error != ""){
                MessageBox.Show("Injection Error: " + error);}
            else{
                System.Environment.Exit(1);}}
        static void Main()
        {
            MessageBox.Show("-[I]fLuX Crossfire Injector\t\nPress 'OK' and start CrossFire");
            Thread t_inject;
            t_inject = new Thread(InjectDll);
            t_inject.Start();
        }
    }
}
