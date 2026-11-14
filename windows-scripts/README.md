# Windows scripts
Windows toolset for build some 3rd party libraries for Win32, Win64 and Arm64

# OSS  Matrix

|   Component   | Version |         Shared            |             |             |             |   Static                      |        |      |       | Depends on | 
| :----------   | ------: | :---------                | :---------: | :---------: | :---------: | :---------                   | :--:   | :--: |:--:   |:-:
|               |         | script                    | x86         | x64         | arm64       |script                        | x86    | x64  | arm64 | 
apr             | 1.7.6   |`cmake_matrix apr`         | ✅          | ✅         | ✅         |                              | ✅     | ✅ | ✅ 
apr-iconv       | 1.2.2   |                           |           | 
apr-util        | 1.6.5   |                           |           |          |          |                               |        |                | |apr openssl pcre2
expat           | 2.9.0   |`cmake_matrix shared expat`| ✅          | ✅         | ✅         | `cmake_matrix static expat`    | ✅     | ✅ | ✅
ffmpeg          | 9.0.2   |`ffmpeg_matrix.cmd`        | ✅          | ✅         | ✅         |                                | ✅     | ✅ | ✅
icu             | 78.3    |                           |           |          | 
openssl         | 3.5.8   |`openssl_matrix.cmd`       | ✅          | ✅         | ✅        |                                | ✅     | ✅  | ✅
pcre2           | 10.49   |`cmake_matrix shared pcre2`| ✅          | ✅         | ✅         | `cmake_matrix static pcre2`    | ✅     | ✅ | ✅
putty           | 0.85    |                           |              |            |             |`cmake_matrix static putty`     | ✅     | ✅ | ✅
qt 5            | 5.15.19 |`qt_matrix.cmd qt5 shared` | ✅          | ✅         | ✅         | `qt_matrix.cmd qt6 static`     | ✅     | ✅| ✅
qt 6            | 6.12.0  |`qt_matrix.cmd qt6 shared` | ✅          | ✅         | ✅         | `qt_matrix.cmd qt6 static`     | ✅     | ✅ |✅         |fmpeg
xalan-c         | 1.12    |    |           |          |            |                                |        |     |           |icu xerces-c
xerces-c        | 3.3.0   |   |           |          |            |                                |        |     |           |icu
zlib            | 1.3.2   |`cmake_matrix shared zlib` | ✅          | ✅         | ✅         | `cmake_matrix static zlib`     | ✅          | ✅         | ✅


## env file
[View](./env "View")

# Windows

* ## Visual Studio
    latest with correct architecture 
    
    configured in `env` file

* ## Nasm

    [Download](https://www.nasm.us/pub/nasm/releasebuilds/ "Go to Downloading")

    latest with correct architecture to PATH
    hardcoded in `bin\conf.cmd`
    
    * _x32_
        ```cmd
        PATH=%PATH%;f:\usr\lib32\nasm`
        ```
    * _x64_
        ```cmd
        PATH=%PATH%;f:\usr\lib64\nasm
        ```
    
    
    // TODO - compile 

* ## Putty
        
    Make this changes to display real version of the compiler
    - **putty-0.XX\cmake\platforms\windows.cmake**
       - Add 
           ```cmake
           if(VSCMD_VER)
               add_compile_definitions("VSCMD_VER=\"${VSCMD_VER}\"")
           endif()
           if(CMAKE_GENERATOR)
               add_compile_definitions("CMAKE_GENERATOR=\"${CMAKE_GENERATOR}\"")
           endif()
           ```
    - **putty-0.XX\utils\buildinfo.c** 
        - Replace 
            ```c++
                put_fmt(buf, "Visual Studio");
            ```
            with
            ```c++
            #if defined CMAKE_GENERATOR
                put_fmt(buf, "%s", CMAKE_GENERATOR);
            #else
                put_fmt(buf, "Visual Studio");
            #endif
            ```
        - add after
            ```c++
            #if 0
                /*
                 * List of _MSC_VER values and their translations taken from
                 * https://docs.microsoft.com/en-us/cpp/preprocessor/predefined-macros
                 *
                 * The pointless #if 0 branch containing this comment is there so
                 * that every real clause can start with #elif and there's no
                 * anomalous first clause. That way the patch looks nicer when you
                 * add extra ones.
                 *
                 * Mostly you can tell the version just from _MSC_VER, but in some
                 * cases, two different compiler versions have the same _MSC_VER
                 * value, and have to be distinguished by _MSC_FULL_VER.
                 */
            ```   
            ```c++
            #elif defined VSCMD_VER
                put_fmt(buf, " (%s)", VSCMD_VER);
            ```
* ## openssl 

    * ### Perl
        hardcoded in `bin\openssl.cmd`

        Download and extract Strawberry Perl portable into `<Strawberry Perl Folder>` 
        and add destiination folder to the PATH

        ```cmd
        PATH=%PATH%;<Strawberry Perl Folder>\perl\bin 
        ```

* ## ffmpeg

    latest supported sources with QT

* ## MSYS2
    
    Install components for build  
    ```sh
    pacman -S make gcc diffutils mingw-w64-{i686,x86_64,clang-aarch64}-pkg-config mingw-w64-{i686,x86_64}-nasm mingw-w64-i686-yasm
    ```
    Update
    ```sh
    pacman -Suy
    ```

    TODO - refactor for different installation location
