with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;
--with Ada.Exceptions;


package body Word_Lists is

	Error: exception;

	procedure Add_Word (List: in out Word_List_Type; 
		                 Word: in ASU.Unbounded_String) is
		    Ptr_Aux: Word_List_Type := List;		-- Me creo puntero aux y se lo asocio a list
			Ptr_Aux2: Word_List_Type := List;
			Count: Natural := 0;
			Salir: Boolean := False;

		 begin
		    
		    if List =  null then	-- si la lista esta vacía		 
		    	List := new Cell'(Word, 1, null);	-- creo una nueva celda, cnt = 1
		    	--Hasta aquí bien!
		   
		    else	-- si la lista no esta vacia
			while not Salir loop
			
				if ASU.To_String(Word) = ASU.To_String(Ptr_Aux.Word) then	-- y la palabra ya esta en la lista
				--Ada.Text_IO.Put_Line("YA ESTA EN LA LISTA");
				Ptr_Aux.Count := Ptr_Aux.Count + 1;	--sube el contador  
				Salir := True;

				elsif Ptr_Aux.Next = null then
					--worAda.Text_IO.Put_Line("Es la ultima");
					--Ada.Text_IO.Put_Line(ASU.To_String(Ptr_Aux.Word));
					Ptr_Aux.Next := new Cell'(Word, 1, null);
					Salir:= True;
				else  
					Ptr_Aux := Ptr_Aux.Next;
				end if;
			end loop;
		    end if;
		end Add_Word;

	procedure Free is new Ada.Unchecked_Deallocation(Cell, Word_List_Type);

	procedure Delete_Word (List: in out Word_List_Type; 
		    	   	Word: in ASU.Unbounded_String) is
		Ptr_Aux: Word_List_Type := List;	-- va a ser el que se recorra la lista desde el 1
		Salir: Boolean := False;
		Ptr_Aux2: Word_List_Type := List;	-- va a ser el que se recorra la lista desde el 1
		begin

			if List = null then	-- si la lista esta vacía
				Ada.Text_IO.Put_Line("LISTA Vacia");
				raise Error;	 
		    		-- Meter un EXCEPT PARA QUE NO ROMPA, RAISE
		  	end if;
	
			if ASU.To_String(Word) = ASU.To_String(List.Word) then
			-- Para el primero de la lista
				--Ada.Text_IO.Put_Line("Entra en borrar");
				Ptr_Aux2 := Ptr_Aux.Next;	-- AUX2 guarda la lista menos el primero
				Free(List);	-- borra toda la lista
				List:= Ptr_Aux2;	-- ahora lista es todo menos el primero.

			else	-- si no es el primero de la lista, tengo que jugar con los punteros
				Ptr_Aux := Ptr_Aux2.Next;	-- llevo p1 detras de p2
				while not Salir loop
				if ASU.To_String(Word) = ASU.To_String(Ptr_Aux.Word) then	-- y la palabra ya esta en la lista
					--Ada.Text_IO.Put_Line("ESTA EN LA LISTA");
					Ptr_Aux2.Next := Ptr_Aux.Next;
					Free(Ptr_Aux);	-- Borro AUX1 que era una celda suelta
					--Ptr_Aux := Ptr_Aux2;
					Salir := True;
				else 	-- si no esta en la lista, la voy recorriendo.
					Ptr_Aux := Ptr_Aux.Next;
					Ptr_Aux2 := Ptr_Aux2.Next;
					-- si recorriendo la lista llego al final y no lo encuentra, salir
					if Ptr_Aux2.Next = null then
						--Ada.Text_IO.Put_Line("Llega al final y no está");
						--Salir:= True;
						raise Error;
					end if;
				end if;
		    		end loop;
		    end if;


	end Delete_Word;


	procedure Search_Word (List: in Word_List_Type;
			                 Word: in ASU.Unbounded_String;
			                 Count: out Natural) is
		Ptr_Aux: Word_List_Type := List;
		Salir: Boolean := False;
		begin
		Count := 0;
		while not Salir loop
			if List = null then
				Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) & "| - " & Integer'Image(0));
				--raise Error;
				return;
			end if;

			if ASU.To_String(Word) = ASU.To_String(Ptr_Aux.Word) then --Cuando es la palabra, pinta la palabra y su contador 
				Count := Ptr_Aux.Count;
				Ada.Text_IO.Put_Line("|" & ASU.To_String(Ptr_Aux.Word) & "|" & Integer'Image(Count));
				Salir:= True;
			elsif Ptr_Aux.Next = null then
				--Ada.Text_IO.Put_Line("NO ESTA");
				Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) & "| -" & Integer'Image(0));
				Salir:= True;
			else	-- si no es esa la palabra, miro la siguiente
				Ptr_Aux := Ptr_Aux.Next;
			end if;
		end loop;

	end Search_Word;

	procedure Max_Word (List: in Word_List_Type; 
		    	   	Word: out ASU.Unbounded_String;
				Count: out Natural) is
		Ptr_Aux: Word_List_Type := List;
		--Count := 0;
		begin
			Count := 0;
			if List = null then
				raise Error;
			end if;

			while Ptr_Aux /=  null loop
			if Ptr_Aux.Count > Count then	-- si el contador es mas pequeño que la frecuencia de la palabra
				Count := Ptr_Aux.Count;	-- me guardo la frecuencia de la plabra
				Word := Ptr_Aux.Word;	-- y la palabra
			else	-- sino:
				Ptr_Aux := Ptr_AUx.Next;	-- sigo buscando
			end if;
			end loop;
		Ada.Text_IO.Put("The most frequent word: ");
		Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) & "| -" & Integer'Image(Count));

	end Max_Word;

	
	procedure Print_All(List: in Word_List_Type) is
	
		P_Aux: Word_List_Type := List;		-- me creo un fichero aux y le digo que lista es eso
											-- pero luego solo modifico el puntero aux, para no perderme 
		begin
			if List = null then
				Ada.Text_IO.Put_Line("No Words.");
			end if;
			while P_Aux /= null loop		-- cuando sea el ultimo
				Ada.Text_IO.Put_Line(" | " & ASU.To_String(P_Aux.Word) -- Imprimo la palabra
						& " | - " & Integer'Image(P_Aux.Count));	-- Imprimo el contador
				P_Aux := P_Aux.Next;		-- para que se recorra la lista
			end loop;

		end Print_All;

	procedure Delete_List (List: in out Word_List_Type) is

		P_Aux: Word_List_Type := List;
		word: ASU.Unbounded_String;
		
		begin
		while P_Aux /= null loop
			word := P_Aux.Word;
			Delete_Word(List, Word);
			P_Aux := P_Aux.Next;
		end loop;
	end Delete_List;

end Word_Lists;
