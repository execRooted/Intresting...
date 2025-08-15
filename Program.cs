using System;
using System.Diagnostics;

class Program
{
    static void Main()
    {
        // Start curl to display ASCII art
        var curlProcess = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "curl",
                Arguments = "ascii.live/can-you-hear-me",
                UseShellExecute = false
            }
        };
        curlProcess.Start();

        // Start mpg123 to play MP3 infinitely (-q quiet, -Z random, or --loop -1 infinite loop)
        var audioProcess = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "mpg123",
                Arguments = "--loop -1 sound.mp3", // Loop forever
                UseShellExecute = false
            }
        };
        audioProcess.Start();

        // Keep the main program alive until curl finishes
        curlProcess.WaitForExit();

        // Optional: Kill audio when curl stops
        try { audioProcess.Kill(); } catch { }
    }
}
