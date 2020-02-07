declare
    l_is_between boolean;
    l_begin_date  date;
    l_end_date    date;
begin
    --Check to ensure that the blind vote dates do not already overlap with existing dates
    l_begin_date := to_date(:P5025_BEGIN_DATE, :DATE_FORMAT_MASK);
    l_end_date   := to_date(:P5025_END_DATE,   :DATE_FORMAT_MASK);

    if l_begin_date is null and l_end_date is null
    then
        return true;
    elsif l_end_date is null
    then
        l_end_date := l_begin_date;
    end if;

    for row in (select e.begin_date begin_date,
                       e.end_date   end_date
                  from ks_events e
                 where 1=1
                   and active_ind = 'Y'
                   and (:P5025_ID is null or (:P5025_ID is not null and :P5025_ID != e.id))
                   and e.event_type = :P5025_EVENT_TYPE
                   
               )
   loop
       if row.end_date is null
       then
           row.end_date := row.begin_date;
       end if;
       

       --Note that the function "between" is inclusive
       l_is_between := (l_begin_date               between row.begin_date   and   row.end_date)
                    or (l_end_date                 between row.begin_date   and   row.end_date)
                    or (row.begin_date             between l_begin_date     and   l_end_date)
                    or (row.end_date               between l_begin_date     and   l_end_date);

       if l_is_between
       then
           return false;
       end if;
   
   end loop;

    return true;

end;