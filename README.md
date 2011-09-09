Jakesmine 
---------

  Jakesmine is a coffee-script based tool for Titanium development.


  OVERVIEW 

  Jakesmine integrates CofeeScript, Jake and Jasmine to your Titanium development
  cycle. 

  Jake is used to define the Jakefile.cofee in pure CoffeeScript, allowing you
  to write coffee-script sources into the Coffee/ directory and get them automatically
  compiled to Resources/ as clean, namespace friendly, js-lint compatible javascripts.

  Jasmine is a javascript BDD framework, and we borrowed Guilherme's Jasmine reporter
  so you can see a window on your emulator executing all your application tests.
  
  Jakesmine uses Titanium's fastdev for its <code>run</code> and <code>test</code>
  in order to improve the development/testing cycle.

  
  CONVENTIONS

    * Any coffee file inside the Coffee directory will be compiled into Resources as
      a javascript file.

    * Test files should be under the Coffee/test/ directory, and they should be
      ended in <code>_test.coffee</code> for example <code>main_test.coffee</code>
      You can of course create subdirectories to organize your tests as you please.
      
    * Test suites should live under the Coffee/test directory. <code>all.coffee</code>
      is the default suite intented to execute all other suites.
      It's the default suite being executed by the <code>test</code> task.

    * Try not to use the word 'should' on your spec descriptions.



  TASKS

    jake -T           # displays help
    jake start        # Start Titanium Fastdev daemon
    jake stop         # Stop Titanium Fastdev daemon
    jake run          # Run application in emulator
    jake test         # Test application in emulator
    jake headless     # Run tests on headless android
    jake android      # Run the android tool
    jake emulator     # Run the emulator
    jake avd          # Run the Android Virtual Device (emulator)
    jake coffee       # Compile files from Coffee into Resources
    jake decafe       # Remove all javascript Resources compiled from Coffee
    jake clean        # Remove generated files
    jake help         # Display usage  


  ENVIRONMENT VARIABLES

  Normally this Jakefile will try to guess your current environment you can
  however force a particular setting by exporting one of the following variables:

    TI_PLATFORM   - The platform for mobile development: 'android' or 'iphone'

                    By default if your OS is Linux, android will be used,
                    on Mac iphone will be selected by default.


    TI_HOME       - The Titanium directory containing mobilesdk/ subdir.

                    On Linux, ~/.titanium if found.
                    On Mac /Library/Application Support/Titanium


    TI_SDK        - The version of the Titanium SDK to use.

                    By default the greatest version installed on $TI_HOME/mobilesdk


    TI_PYTHON     - The python executable to run Titanium scripts.

                    By default the python found in PATH


    ANDROID_SDK   - The location of the Android development kit.

                    Default: none.


    AVD           - The Android virtual device to use for development.

                    Default: none.
