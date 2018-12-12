%This is a simple illustration of how to implement a staircase in an experiment 
%using PsychToolBox. You give a response every trial and based on getting it  
%correct or incorrect another variable changes. 

%Keep an eye on the console to see the output

%This is just a for loop where you have to press a number on the keypad
%for a correct response (number can be from 1-9 in this case) or 
%basically any other key (including 0) for incorrect response.

%If you get x number of correct responses the number for correct will go up
%and if you get an incorrect response the number will go down.
%The staircase controls the number of correct responses required to go up 
%or down.

%In the initial example you just have to press the num_1 key 3 times in a
%row for it to go up to num_2, then num_3, etcetera. If you press the wrong
%key, it will go down 1 step so from num_3 to num_2 and so on.

%Because the example experiment is so small I didn't initialise all the 
%parameters but instead just add them in the loop. For a real experiment
%it is better to pre-allocate these to improve experiment timings.

try
    %Useful when testing/debugging as it doesn't stop due to technical issues
    %Do not use this in an actual experiment that is up and running
    Screen('Preference', 'SkipSyncTests', 1);
    %% Set up screen for experiment
    HideCursor; %You don't want to see the mouse cursor
    whichScreen = max(Screen('Screens')); %Identify the screen
    white = WhiteIndex(whichScreen); %Useful for finding the right colour code
    black = BlackIndex(whichScreen);
    grey = GrayIndex(whichScreen);
    
    %Get the screen resolution and open a small window rather than full screen
    res = Screen('Resolution', whichScreen); 
    [w, rect] = Screen('Openwindow', whichScreen, white, [0 0 res.width/2 res.height/2], [], 2);
    %w is your opened window, rect is the size of the opened window
    
    %It's useful to sync your stimulus presentation to the window refresh rate
    ifi=Screen('GetFlipInterval', w);
    frame_rate = 1/ifi;
    waitFrames = 1;
    %Set up your keyboard so that you get the right keycodes
    KbName('UnifyKeyNames');
    deviceIndex = GetKeyboardIndices;
    
    %Some instructions
    DrawFormattedText(w,'Some Instructions', 'center', 'center', black, 0,0,0,1.5);
    vbl = Screen('Flip',w); %flip the screen to show the text and store the timestamp
    
    %This loop waits for a keypress and if you press the spacebar the loop will
    %break and continue and you press the escape key the experiment will exit.
    while 1
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            KbQueueStop;
            break
        elseif keyCode(KbName('escape'))==1
            sca;
            return
        end
    end

    %Initialise some parameters
    correct = 0; %Nothing correct yet
    current = 1; %Starting value, will make sense later
    minVal = 1; %Lowest possible value, will make sense later
    maxVal = 9; %Highest possible value, will make sense later
    
    %Let's make a structure to store experiment output
    exp = struct;
    exp.nTrials = 20; %we'll loop through these
    exp.stairCase = 3; %to start with
    
    %Easy example of how to implement different staircases
    if exp.stairCase == 3
        exp.stairUp = 3;
        exp.stepSize = 1;
    elseif exp.stairCase == 2
        exp.stairUp = 2;
        exp.stepSize = 1;
    elseif exp.stairCase  == 1
        exp.stairUp = 1;
        exp.stepSize = 1;
    end
    
    for thisTrial = 1:exp.nTrials
        %This example just stores the current trial number in the structure we
        %made at the row index that matches the for loop index
        exp.trial(thisTrial) = thisTrial;
                
        %Specify what to show on the screen
        screenText = WrapString(['Please press ' num2str(current) '.']);
        DrawFormattedText(w, screenText, 'center', 'center', [0 0 0], 0,0,0,1.5);
        
        %This syncs the presentation (flip) to the refresh rate so that you
        %never get a flip in the middle of a screen refresh
        vbl = Screen('Flip',w, vbl + (waitFrames - 0.5) * ifi);
        
        %Wait for a response and record the output
        keyIsDown = 0; %no key is pressed yet 
        while ~keyIsDown
            [keyIsDown, secs, keyCode, ~] = KbCheck(deviceIndex);
            resp = KbName(find(keyCode));
            %always add an option to quit a loop
            if keyCode(KbName('escape'))==1
                ShowCursor;
                sca;
                return
            end            
        end
        
        %uncomment resp below to see the response each time, I had to use this to
        %figure out why num_1 did work and 1 did not work on my keyboard :)
        %resp 
        resp = str2double(resp);
        
        %Get rid of any keypresses before the next query
        KbEventFlush;
        %Flip the screen after a response
        vbl = Screen('Flip',w, vbl + (waitFrames - 0.5) * ifi);
        WaitSecs(0.5);
        
        %Count correct responses in a row
        if resp==current
            correct = correct+1;
        else
            correct = 0;
        end
        
        %Print the output to make it easy to see what is happening
        disp(['Trial number ' num2str(thisTrial) ': ' num2str(correct) ' correct responses'])
        
        %store the output in the experiment structure
        exp.resp(thisTrial) = resp;
        exp.correct(thisTrial) = correct;
        %If correct responses in a row is equal to staircase number and not yet maxed out
        %go up by specified step
        if correct == exp.stairUp && current < maxVal
            disp([num2str(exp.stairCase) ' correct in a row, going up!'])
            current = current + exp.stepSize;
            %Important to reset the streak each time you go up
            %This makes sure that the keypress will never go lower than 1
            %as you want some kind of floor and ceiling to the staircase
            correct = 0;  
        elseif correct == 0 && current > minVal
            disp(['Wrong! Going down by ' num2str(exp.stepSize) '!'])
            current = current - exp.stepSize;
        end
    end
    %This is useful for closing the experiment window when there's an error
catch ME
    ShowCursor;
    sca;
    rethrow(ME);
end

ShowCursor;
sca;

%take a look at the exp structure in your workspace to see the stored output

