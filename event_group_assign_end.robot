*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Start\\s*event\\s*group
...    Start\\s*assigned\\s*event\\s*group\\s*
...    Assigned\\s*event\\s*group\\s*notification\\s*event\\s*received\\s*after\\s*[1-9]+[0-9]*\\s*data\\s*events\\.
...    "Normal"\\s*event\\s*group\\s*notification\\s*event\\s*received\\s*after\\s*2048\\s*data\\s*events\\.
...    Cycles\\s*curr:[1-9]+[0-9]*,\\s*ave:[0-9]+
...    Chained\\s*event\\s*group\\s*done

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Event Group Assign End
    [Documentation]    event_group_assign_end -c ${core_mask} -${mode}

    # Run application
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    25s

    # Terminate application
    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    List Should Contain Value    ${rc_list}    ${output.rc}    Return Code: ${output.rc}

    # Match terminal output
    FOR    ${line}    IN    @{match}
        Should Match Regexp    ${output.stdout}    ${line}
    END
    FOR    ${line}    IN    @{do_not_match}
        Should Not Match Regexp    ${output.stdout}    ${line}
    END

    # Match pool statistics
    FOR    ${line}    IN    @{pool_statistics_match}
        Should Match Regexp    ${output.stdout}    ${line}
    END
