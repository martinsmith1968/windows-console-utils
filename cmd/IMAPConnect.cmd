@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SERVERNAME=%~1
SET SERVERPORT=%~2
SET USERNAME=%~3
SET PASSWORD=%~4

IF /I "%SERVERNAME%" == "/?" (
    CALL :USAGE
    GOTO :EOF
)

IF "%SERVERNAME%" == "" (
    CALL :ERROR Invalid Server Name
    CALL :USAGE
    GOTO :EOF
)
IF "%SERVERPORT%" == "" (
    CALL :ERROR Invalid Server Port
    CALL :USAGE
    GOTO :EOF
)
IF "%USERNAME%" == "" (
    CALL :ERROR Invalid User Name
    CALL :USAGE
    GOTO :EOF
)

:DOIT
TELNET "%SERVERNAME%" "%SERVERPORT%"





elnet: > telnet imap.example.com imap
telnet: Trying 192.0.2.2...
telnet: Connected to imap.example.com.
telnet: Escape character is '^]'.
server: * OK Dovecot ready.
client: a1 LOGIN MyUsername MyPassword
server: a1 OK Logged in.
client: a2 LIST "" "*"
server: * LIST (\HasNoChildren) "." "INBOX"
server: a2 OK List completed.
client: a3 EXAMINE INBOX
server: * FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
server: * OK [PERMANENTFLAGS ()] Read-only mailbox.
server: * 1 EXISTS
server: * 1 RECENT
server: * OK [UNSEEN 1] First unseen.
server: * OK [UIDVALIDITY 1257842737] UIDs valid
server: * OK [UIDNEXT 2] Predicted next UID
server: a3 OK [READ-ONLY] Select completed.
client: a4 FETCH 1 BODY[]
server: * 1 FETCH (BODY[] {405}
server: Return-Path: sender@example.com
server: Received: from client.example.com ([192.0.2.1])
server:         by mx1.example.com with ESMTP
server:         id <20040120203404.CCCC18555.mx1.example.com@client.example.com>
server:         for <recipient@example.com>; Tue, 20 Jan 2004 22:34:24 +0200
server: From: sender@example.com
server: Subject: Test message
server: To: recipient@example.com
server: Message-Id: <20040120203404.CCCC18555.mx1.example.com@client.example.com>
server: 
server: This is a test message.
server: )
server: a4 OK Fetch completed.
client: a5 LOGOUT
server: * BYE Logging out
server: a5 OK Logout completed.