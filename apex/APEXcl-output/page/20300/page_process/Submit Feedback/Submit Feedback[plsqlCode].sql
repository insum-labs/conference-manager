declare
  l_to ks_parameters.value%TYPE;
  l_from varchar2(200);
  g_email_prefix ks_parameters.value%TYPE;
  l_body clob;
  l_subject varchar2(200);
  i number;
begin

  apex_util.submit_feedback (
      p_comment         => :P20300_FEEDBACK,
      p_type            => :P20300_FEEDBACK_TYPE,
      p_application_id  => :P20300_APPLICATION_ID,
      p_page_id         => :P20300_PAGE_ID,
      p_email           => null);

  l_to := ks_util.get_param('FEEDBACK_EMAIL');
  l_from := nvl(ks_util.get_email(:APP_USER), 'jorge@rimblas.com');
  g_email_prefix := ks_util.get_param('EMAIL_PREFIX');
  l_body := 'New feedback for page (on Review App): ' || :P20300_APPLICATION_ID || '.' || :P20300_PAGE_ID || utl_tcp.crlf
   || 'From: ' || :APP_USER || utl_tcp.crlf
   || utl_tcp.crlf
   || :P20300_FEEDBACK || utl_tcp.crlf;

  i :=  instr(:P20300_FEEDBACK, chr(10));
  if i = 0 or i > 80 then
    -- if the first line entered is too long or it's all in one line
    -- then grab the first 90 charachters entered by the user
    i := 90;
  end if;

  l_subject := g_email_prefix || 'Feedback: ' || substr(:P20300_FEEDBACK, 1, i);

  apex_mail.send(p_to   => l_to
               , p_from => l_from
               , p_subj => l_subject
               , p_body => l_body);
end;