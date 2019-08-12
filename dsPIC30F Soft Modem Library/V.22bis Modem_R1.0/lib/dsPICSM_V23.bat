@Echo .... Building dsPICSM_V23.a Soft-Modem Archive ....
@SET COMPILER_PATH=E:\pic30_tools\bin\
@SET C_INCLUDE_PATH=e:\pic30_~1\include
@SET TMPDIR=lib\temp

pic30-ar -r dsPICSM_V23.a ..\source\obj\callprog.o
pic30-ar -r dsPICSM_V23.a ..\source\obj\data.o 
pic30-ar -r dsPICSM_v23.a ..\source\obj\dmctrl.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\filter.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\agc.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\mdmkern.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\message.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\modemvar.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\signal.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\sipl.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\tables.o 
pic30-ar -r dsPICSM_v23.a ..\source\obj\toned.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\v23.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\v21.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\v8.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\v25.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\rtd.o 
pic30-ar -r dsPICSM_v23.a ..\source\obj\dtmfgen.o 
pic30-ar -r dsPICSM_V23.a ..\source\obj\dtmftables.o


@Echo .... dsPICSM_V23.a Soft-Modem Archive Build Complete ....