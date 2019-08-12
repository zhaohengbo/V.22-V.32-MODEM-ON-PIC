@Echo .... Building dsPICSM_V32bisse.a Soft-Modem Archive ....
@SET COMPILER_PATH=E:\pic30_tools\bin\
@SET C_INCLUDE_PATH=e:\pic30_~1\include
@SET TMPDIR=lib\temp

pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\callprog.o
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\carrec.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\data.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\dmctrl.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\ec.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\eqz.o
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\filter.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\hdlc.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\agc.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\mdmkern.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\message.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\modemvar.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\psf.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\sbar.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\signal.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\sipl.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\tables.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\toned.o
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\trel.o
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v32bis.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v32ec.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v32rr.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\viterbi.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v21.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v8.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v25.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\rtd.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42bf.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42if.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42m.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42main.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42n.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\v42pf.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\dtmfgen.o 
pic30-ar -r dsPICSM_V32bisse.a ..\source\obj\dtmftables.o


@Echo .... dsPICSM_V32bisse.a Soft-Modem Archive Build Complete ....