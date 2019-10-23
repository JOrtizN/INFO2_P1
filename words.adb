with word_lists;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Characters.Handling;
with Ada.Strings.Maps;




procedure Words is
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   
   Usage_Error: exception;

   Word: ASU.Unbounded_String;
   Count: Natural;
 
   List: Word_Lists.Word_List_Type;
   User_Input: ASU.Unbounded_String;
   
   File_Name: ASU.Unbounded_String;
   File: Ada.Text_IO.File_Type;
 
   Finish: Boolean;
   Line: ASU.Unbounded_String;
   Respuesta: ASU.Unbounded_String;


	procedure MENU is
	begin
		ADA.Text_IO.New_Line(1);
		ADA.Text_IO.Put_Line("Options");
		ADA.Text_IO.Put_Line("1 Add word");
		ADA.Text_IO.Put_Line("2 Delete word");
		ADA.Text_IO.Put_Line("3 Search word");
		ADA.Text_IO.Put_Line("4 Show all words");
		ADA.Text_IO.Put_Line("5 Quit");
		ADA.Text_IO.New_Line(1);
	end MENU;

	procedure Div_Line(Line: in out ASU.Unbounded_String) is
		-- tengo que buscar los espacios que separan las palabras
		P_Esp: Natural;		--Posicion del espacio
		Salir: boolean := False;
		Palabra: ASU.Unbounded_String;
	begin
		while not Salir loop
		P_Esp:= Asu.Index(Line, Ada.Strings.Maps.To_Set(" (),<>-.ç/-+º'¡!¿?$~%&=*;:'^`[]1234567890")); -- busca la posicion del espacio en la linea
		
		if ASU.Length(Line) = 0 then	-- si la linea esta vacia dejo de buscar
			Salir := True;
		elsif P_Esp = 0 then	-- significa que no tiene espacios
			--Ada.Text_IO.Put("P_EsP 0 --->");
			--Ada.Text_IO.Put_Line(ASU.To_String(Line)); -- Da la palabra
			Word_Lists.Add_Word(List, Line);
			Salir := True;
		elsif P_Esp = 1 then 	-- La linea empieza por espacio
			-- Uso TAIL para quitarme el espacio a la linea
			--Ada.Text_IO.Put("P_EsP 1 --->");			
			Line := ASU.Tail(Line, ASU.Length(Line)-1);  --Devuelve todo a la derecha del index
			--Ada.Text_IO.Put(ASU.To_String(Line));
		else
		-- Para cualquier otra posicion me tengo que guardar
		-- Lo de antes del espacio en una palabra
		-- lo de despues del espacio en linea para volver a trocear ese cacho
		Palabra := ASU.Head(Line, P_Esp-1); --Head saca lo de la derecha de arg1 desde el valor de arg2
		--Ada.Text_IO.Put_Line("ELSE --->" & ASU.To_String(Palabra));
		-- BIEN YA, Me guardo la palabra en la lista
		--Ada.Text_IO.Put_Line("Añadiendo a la lista");
		Word_Lists.Add_Word(List, Palabra);


		Line := ASU.Tail(Line, ASU.Length(Line)-P_Esp);  -- Nueva linea tras quitarle la palabra
		--Ada.Text_IO.Put_Line("LINE:   " & ASU.To_String(Line)); -- Da la palabra
		end if;		-- ya estan todas las posibilidades

		end loop;
	end Div_Line;


	procedure Div_Text(File: Ada.Text_IO.File_Type) is

		Fin:  Boolean := False;
		Line: ASU.Unbounded_String;
	begin
		while not Fin loop
		begin 
			Line := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(File));
			Div_Line(Line);
		exception 
			when Ada.IO_Exceptions.End_Error =>
				Fin := True;
			end;
		end loop;
	end Div_Text;


begin
	Finish:= False;
   	if ACL.Argument_Count = 1 then
		File_Name := ASU.To_Unbounded_String(ACL.Argument(1));   
 	        Ada.Text_IO.Open(File, Ada.Text_IO.In_File, ASU.To_String(File_Name));
   		Div_Text(File);
   		Word_Lists.Max_Word(List, Word, Count);
		ADA.Text_IO.New_Line(1);
		Word_Lists.Delete_List(List);

	elsif ACL.Argument_Count = 2 and ACL.Argument(1) = "-i" then
		File_Name := ASU.To_Unbounded_String(ACL.Argument(2));   
 	        Ada.Text_IO.Open(File, Ada.Text_IO.In_File, ASU.To_String(File_Name));
		MENU;
		Div_Text(File);
		while not Finish loop
			Ada.Text_IO.Put("Your option? ");
			Respuesta := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			ADA.Text_IO.New_Line(1);
			if ASU.To_String(Respuesta) = "1" then
				Ada.Text_IO.Put("Word? ");
	      			Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Div_Line(Word);
				Word_Lists.Add_Word(List, Word);
				ADA.Text_IO.New_Line(1);
			Ada.Text_IO.Put_Line("Word |" & ASU.To_String(Word) & "| added");
				MENU;
			elsif ASU.To_String(Respuesta) = "2" then
				Ada.Text_IO.Put("Word? ");
				Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				ADA.Text_IO.New_Line(1);
				Word_Lists.Delete_Word(List, Word);
				Ada.Text_IO.Put_Line("Word |" & ASU.To_String(Word) & "| Deleted");
				MENU;
			elsif ASU.To_String(Respuesta) = "3" then
				Ada.Text_IO.Put("Word? ");
				Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				ADA.Text_IO.New_Line(1);
				Word_Lists.Search_Word(List, Word, Count);
				MENU;
			elsif ASU.To_String(Respuesta) = "4" then
				Word_Lists.Print_All(List);
				MENU;
			elsif ASU.To_String(Respuesta) = "5" then
				Word_Lists.Max_Word(List, Word, Count);
				ADA.Text_IO.New_Line(1);
				Finish := True;
			else
				Ada.Text_IO.Put_Line("Option out of range");
				MENU;
			end if;
		end loop;
		Word_Lists.Delete_List(List);

	
	else
		raise Usage_Error;
	end if;

	Ada.Text_IO.Close(File);

exception
   
   when Usage_Error =>
      	Ada.Text_IO.Put_Line("Usage: word [-i] <Filename>");

   when Constraint_Error =>
	Ada.Text_IO.Put_Line("Usage: word [-i] <Filename>");

   when Ada.IO_Exceptions.Name_Error =>
	Ada.Text_IO.Put(ASU.To_String(File_Name));
   	Ada.Text_IO.Put_Line(": File not found");

   when Except: others =>
	Ada.Text_IO.Put_Line("WORD_LIST_ERROR!!");
   
end Words;
