                                                 
               _   _____ __    _____ _____ ____  
       ___ ___| |_| __  |  |  |   __|   | |    \ 
      | . | . |  _| __ -|  |__|   __| | | |  |  |
      |_  |  _|_| |_____|_____|_____|_|___|____/ 
      |___|_|                                    

# gptBLEND
      Describe the 3D model you want to create in plain English, and the script will generate the corresponding Python code that Blender can understand. It's like having a magical genie at your fingertips!

Imagine you are a wizard with the power to create 3D models in Blender, but instead of waving a wand or muttering incantations, you use natural language. That's what my script does!

   • Open a terminal window.
   • Navigate to the directory where the script is located.
   • Run the script using the command ./gptBLEND.sh (when using linux based system) and gptBLEND.bat (when using windows based system)
   • Read the usage instructions that are displayed in the terminal.
   • Enter a prompt that describes the Python code you want to generate.
      For example, "Generate Python code to create a 3D model of a car in Blender."
   • Press Enter to submit the prompt.
   • The script will validate the prompt and send a request to the ChatGPT API to generate Python code.
   • If the API response includes generated Python code, the script will save the code to a file named script.py and execute the code in Blender.
   • If there are any errors during the process, the script will print an error message and exit.

Note that you should replace "YOUR_API_KEY" with your actual API key for the ChatGPT API. Additionally, make sure you have installed the jq tool to extract the generated Python code from the API response.

      p.s. if there is any problem while running just remove the banner part ;)
