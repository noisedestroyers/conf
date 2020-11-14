/******************************************************************************************
* MIT License
*
* Copyright (c) 2013-2017 Sensel, Inc.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
******************************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

using Sensel;

using Commons.Music.Midi;

namespace SenselExamples
{
    class SenselContacts
    {
        

        static void Main(string[] args)
        {
            new Program(args);
            return;
        }
    }
    public class ContactList
    {
        public SenselContact[] Contact = new SenselContact[3];

        public bool isActive;
        public bool isFirstStrike;
        public int MidiNote;
        public int MidiVel;
    }

    class Program
    {
        public Dictionary<int, ContactList> Contacts = new Dictionary<int, ContactList>();
        

        public Program(string[] args)
        { 
            Stopwatch sw = new Stopwatch();

            for (int i = 0; i < 16; i++) Contacts.Add(i, new ContactList());

            SenselDeviceList list = SenselDevice.GetDeviceList();
            Console.WriteLine("Num Devices: " + list.num_devices);
            if (list.num_devices == 0)
            {
                Console.WriteLine("No devices found.");
                Console.WriteLine("Press any key to exit.");
                while (!Console.KeyAvailable) { }
                return;
            }

            // Configure Sensel
            SenselDevice sd = new SenselDevice();
            sd.OpenDeviceByID(list.devices[0].idx);
            sd.SetMaxFrameRate(2000);
            sd.SetFrameContent(SenselDevice.FRAME_CONTENT_CONTACTS_MASK);
            sd.SetContactsMask(SenselDevice.CONTACT_MASK_PEAK);
            sd.SetScanDetail(SenselScanDetail.SCAN_DETAIL_LOW);

            // Configure Midi
            var access = MidiAccessManager.Default;
            var midiOut = access.OpenOutputAsync(access.Outputs.Where(o => o.Name.Contains("sendrum")).First().Id).Result;


            Console.WriteLine("Press any key to exit");

            Console.Clear();
            sw.Start();
            int framecount = 0;
            sd.StartScanning();
            while (!Console.KeyAvailable)
            //for (int s = 0; s < 1000; s++)
            {
                if (framecount % 1000 == 0)
                {
                    
                    Console.SetCursorPosition(0, 0);
                    Console.WriteLine($"FPS: {(float)framecount * 1000 / sw.ElapsedMilliseconds}          ");
                    framecount = 0;
                    sw.Reset(); sw.Start();
                }

                framecount++;
                sd.ReadSensor();
                int num_frames = sd.GetNumAvailableFrames();
                for (int f = 0; f < num_frames; f++)
                {
                    SenselFrame frame = sd.GetFrame();
                    if (frame.n_contacts > 0)
                    {
                        //Console.WriteLine("\nNum Contacts: " + frame.n_contacts);
                        for (int i = 0; i < frame.n_contacts; i++)
                        {
                            //Console.WriteLine("Contact ID: " + frame.contacts[i].id);
                            if (frame.contacts[i].state == (int)SenselContactState.CONTACT_START)
                            {
                                Contacts[i].Contact[0] = frame.contacts[i];
                                Contacts[i].isFirstStrike = true;
                                Contacts[i].isActive = true;

                                var vel = frame.contacts[i].peak_force;
                                var vel2 = frame.contacts[i].area;

                                midiOut.Send(new byte[] { MidiEvent.NoteOn, (byte)(70+i), 0x7F }, 0, 3, 0);
                                sd.SetLEDBrightness(frame.contacts[i].id, 100);
                            }
                            else if (frame.contacts[i].state == (int)SenselContactState.CONTACT_END)
                            {
                                Contacts[i].isActive = false;
                                Contacts[i].Contact[2] = frame.contacts[i];
                                midiOut.Send(new byte[] { MidiEvent.NoteOff, (byte)(70 + i), 0x7F }, 0, 3, 0);
                                sd.SetLEDBrightness(frame.contacts[i].id, 0);
                            }
                            else
                            {
                                if (Contacts[i].isFirstStrike)
                                {
                                    Contacts[i].isFirstStrike = false;
                                    Contacts[i].Contact[1] = frame.contacts[i];
                                }
                                else
                                {
                                    Contacts[i].isFirstStrike = false;
                                    Contacts[i].Contact[2] = frame.contacts[i];
                                }
                            }

                            UpdateConsole(i);
                        }
                    }
                }
            }
            sw.Stop();
            Console.Write($"Frames: {framecount} in {sw.ElapsedMilliseconds} ms");
            byte num_leds = sd.GetNumAvailableLEDs();
            for(int i = 0; i < num_leds; i++)
            {
                sd.SetLEDBrightness((byte)i, 0);
            }
            sd.StopScanning();
            sd.Close();
        }

        void UpdateConsole(int i)
        {
            Console.SetCursorPosition(0, i + 2);
            string o = $"{i,-3} {(Contacts[i].isActive ? "X" : " ")}";
            o = o + $"{Contacts[i].Contact[0].peak_force,-6}";
            o = o + $"{Contacts[i].Contact[0].area,-6}";
            o = o + "   ";
            o = o + $"{Contacts[i].Contact[1].peak_force,-6}";
            o = o + $"{Contacts[i].Contact[1].area,-6}";
            o = o + "   ";
            o = o + $"{Contacts[i].Contact[2].peak_force,-6}";
            o = o + $"{Contacts[i].Contact[2].area,-6}";
            Console.Write(o);
        }
    }
}
