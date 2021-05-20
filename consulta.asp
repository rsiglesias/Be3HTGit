<% 
'<meta http-equiv="Content-Language" content="pt-br">
Response.contentType = "application/json" 
Response.charset="UTF-8"
Response.AddHeader "Content-language", "pt-br"
Session.LCID = 1046

	'On Error Resume Next
    Dim Comando
    Dim Arquivo
    Dim SQL
    Dim ADOConn, RS, A
    Dim Saida
	Saida = "{""ret"":-100, ""msg"":""Nenhuma opção selecionada.""}"

	'Provider=MSDASQL;
	Application("StrConn") = "Provider=MSDASQL;Driver={SQL Server};Server=db_sql.be3.co,1515;Database=DB;Uid=teste.be3;Pwd=ProcSeletivo#2020"
	'Application("StrConn") = "Provider=sqloledb;Network Library=DBMSSOCN;Data Source=db_sql.be3.co,1515;Initial Catalog=DB;User ID=teste.be3;Password=ProcSeletivo#2020;"
	Saida = "{""ret"":0, ""msg"":""Novo cadastro "& Application("StrConn") &"""}"

    Set ADOConn = Server.CreateObject("ADODB.Connection")
    Set RS = Server.CreateObject("ADODB.RecordSet")

    ADOConn.Open Application("StrConn")
	If Err<>0 Then Saida = "{""ret"":-1, ""msg"":""Erro no sistema: " & Err.Description & """}"

    Saida = ""
    Comando = Request.Form("Comando")
'	Saida = "{""ret"":0, ""msg"":""Comando "& Comando &"""}"
    Select Case Comando
    Case "ConsultaProntuario"
        Dim c_Pront, cp_SQL
		On Error Resume Next
		If Err = 0 Then
			c_Pront = Request.Form("Pront")
			cp_SQL = "SELECT Prontuario, Nome, Sobrenome, Format(Dt_Nasc, 'dd/MM/yyyy') Dt_Nasc, RG, UFRG, CPF, Sexo, Fone_Res, Email, ID_Convenio, N_Carteirinha, Celular, Nome_Mae, Format(Dt_Carteirinha, 'MM/yyyy') Dt_Carteirinha FROM Clientes WHERE Prontuario = "& c_Pront
			RS.Open cp_SQL, ADOConn
		End If
		If Err = 0 Then
			If RS.EOF Then
				%>
				{"ret":0, "msg":"Novo cadastro <%=c_Pront%>"}<%
			Else
				%>{"ret":1, "msg":"Busca OK"<%

				For A=0 To RS.Fields.Count
					%>, "<%=lcase(RS.Fields(A).Name)%>":"<%=RS(A)%>"<%
				Next

				%>}<%
			End If
		Else
			%>
			{"ret":-1, "msg":"Erro <%=Err.Description%> <%=c_Pront%>"}<%
		End If
    Case "ConsultaConvenios"
		On Error Resume Next
        RS.Open "SELECT id_Convenio, Empresa FROM Convenios", ADOConn
        If RS.EOF Then
			%>
            {"ret":0, "msg":"Nenhum convênio encontrado"}<%
        Else
            %>{"ret":1, "msg":"Busca OK", "convenios":[<%

			Do Until RS.EOF
				%>{<%
				'For A=0 To RS.Fields.Count
					%>"<%=lcase(RS.Fields(0).Name)%>":"<%=RS(0)%>"<%
					%>, "<%=lcase(RS.Fields(1).Name)%>":"<%=RS(1)%>"<%
				'Next
				%>}<%
				RS.MoveNext
				If Not RS.EOF Then
					%>, <%
				End If
			Loop

			%>]}<%
        End If
    Case "ConsultaCPF"
		On Error Resume Next
        Dim CPF, CPF_Pront
        CPF = Trim(Request.Form("CPF"))
		CPF_Pront = Trim(Request.Form("Pront"))
		If CPF = "" Then
			%>
            {"ret":-1, "msg":"CPF em branco"}<%
		Else
			RS.Open "SELECT Prontuario, Nome, Sobrenome FROM Clientes WHERE CPF = '"& CPF &"' ORDER BY ABS(Prontuario - " & CPF_Pront & ") DESC;", ADOConn
			If RS.EOF Then
				%>
				{"ret":0, "msg":"Novo CPF"}<%
			Else
				If CPF_Pront = Trim(RS("Prontuario")) Then
					%>{"ret":0, "msg":"CPF OK para este prontuario."<%

					For A=0 To RS.Fields.Count
						%>, "<%=LCase(RS.Fields(A).Name)%>":"<%=RS(A)%>"<%
					Next

					%>}<%
				Else
					%>{"ret":1, "msg":"CPF já cadastrado sob o prontuário <%=RS("Prontuario")%> (<%=RS("Nome") & " " & RS("Sobrenome")%>) "<%

					For A=0 To RS.Fields.Count
						%>, "<%=LCase(RS.Fields(A).Name)%>":"<%=RS(A)%>"<%
					Next

					%>}<%
				End If

			End If
		End If
    Case "InsereProntuario"
        Dim i_Pront, i_Nome, i_Sobrenome, i_DtNasc, i_RG, i_UFRG, i_CPF, i_Sexo, i_Fixo, i_Email, i_Conv, i_CConv, i_Cel, i_NomeMae, i_CCData
		Dim i_SQL
		i_Nome = Request.Form("Nome")
		i_Sobrenome = Request.Form("Sobrenome")
		i_DtNasc = Request.Form("dt_nasc")
		i_RG = Request.Form("rg")
		i_UFRG = Request.Form("ufrg")
		i_CPF = Request.Form("cpf")
		i_Sexo = Request.Form("sexo")
		If Trim(i_Sexo) = "" Then i_Sexo = 0
		i_Fixo = Request.Form("fone_res")
		i_Email = Request.Form("email")
		i_Conv = Request.Form("id_Convenio")
		i_CConv = Request.Form("n_carteirinha")
		i_Cel = Request.Form("celular")
		i_NomeMae = Request.Form("nome_mae")
		i_CCData = Request.Form("dt_carteirinha")
		If Len(i_CCData) > 7 Then i_CCData = Format(Request.Form("dt_carteirinha"), "mm/yyyy")

        'i_Pront = Request.Form("Pront")
		i_SQL = "insert into clientes (Nome, Sobrenome, Dt_Nasc, rg, ufrg, cpf, sexo, fone_res, email, id_Convenio, n_carteirinha, celular, nome_mae, dt_carteirinha) SELECT '" & i_Nome & "', '" & i_Sobrenome & "', '" & i_DtNasc & "', '" & i_rg & "', '" & i_ufrg & "', '" & i_cpf & "', '" & i_sexo & "', '" & i_fixo & "', '" & i_email & "', '" & i_Conv & "', '" & i_CConv & "', '" & i_cel & "', '" & i_nomemae & "', '01/" & i_CCData & "';"
		i_Pront = 0
		On Error Resume Next
		ADOConn.Execute(i_SQL)
		If Err = 0 Then
			RS.Open "Select @@IDENTITY ID;", ADOConn
		End If
		If Err = 0 Then
			If RS.EOF Then
				%>{"ret":0, "msg":"Algum problema ocorreu, tente novamente."}<%
			Else
				i_Pront = RS("ID")
				%>{"ret":1, "msg":"Inserido OK: Prontuário <%=i_Pront%>", "pront":"<%=i_Pront%>"}<%
			End If
		Else
			%>{"ret":0, "msg":"Algum problema ocorreu, tente novamente. <%=Err.Description%>"}<%
		End If
    Case "AtualizaProntuario"
		On Error Resume Next
        Dim u_Pront, u_Nome, u_Sobrenome, u_DtNasc, u_RG, u_UFRG, u_CPF, u_Sexo, u_Fixo, u_Email, u_Conv, u_CConv, u_Cel, u_NomeMae, u_CCData
		Dim u_SQL, RecAffected
		u_Nome = Trim(Request.Form("Nome"))
		u_Sobrenome = Trim(Request.Form("Sobrenome"))
		u_DtNasc = Trim(Request.Form("dt_nasc"))
		'u_DtNasc = Format(u_dtnasc, "yyyy-mm-dd")
		u_RG = Trim(Request.Form("rg"))
		u_UFRG = Trim(Request.Form("ufrg"))
		u_CPF = Trim(Request.Form("cpf"))
		u_Sexo = Trim(Request.Form("sexo"))
		If Trim(u_Sexo) = "" Then u_Sexo = 0
		u_Fixo = Trim(Request.Form("fone_res"))
		u_Email = Trim(Request.Form("email"))
		u_Conv = Trim(Request.Form("id_Convenio"))
		u_CConv = Trim(Request.Form("n_carteirinha"))
		u_Cel = Trim(Request.Form("celular"))
		u_NomeMae = Trim(Request.Form("nome_mae"))
		u_CCData = Trim(Request.Form("dt_carteirinha"))
		If Len(u_CCData) > 7 Then u_CCData = Format(Request.Form("dt_carteirinha"), "mm/yyyy")

        u_Pront = Request.Form("Pront")
		u_SQL = "update clientes set Nome = '" & u_Nome & "', Sobrenome = '" & u_Sobrenome & "', Dt_Nasc = '" & u_DtNasc & "', rg = '" & u_rg & "', ufrg = '" & u_ufrg & "', cpf = '" & u_cpf & "', sexo = " & u_sexo & ", fone_res = '" & u_fixo & "', email = '" & u_email & "', id_Convenio = " & u_Conv & ", n_carteirinha = '" & u_cconv & "', celular = '" & u_cel & "', nome_mae = '" & u_nomemae & "', dt_carteirinha = '01/" & u_CCData & "' WHERE Prontuario = "& u_Pront
        ADOConn.Execute u_SQL
        If Err <> 0 Then
			%>{"ret":0, "msg":"Algum problema ocorreu, tente novamente. <%=Err.Description%>"}<%
        Else
            %>{"ret":1, "msg":"Atualizado OK."}<%
        End If
    End Select
    ADOConn.Close
%>