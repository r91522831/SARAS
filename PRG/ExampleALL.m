% Example of managing all SARAS files

clear all

init;

Txt2File = [];
for Group = 'acp'
    switch Group
        case 'c'
            ParticpantNumber = CONTROL_NB;
        case 'a'
            ParticpantNumber = AGED_NB;
        case 'p'
            ParticpantNumber = PATIENT_NB;
        otherwise
            disp(Group)
    end
    for Subj = ParticpantNumber
        for Trial = 1:2
            fname     = sprintf('%sp%02.0f-%1.0f.dat',  Group, Subj, Trial );
            %disp(fname)
            Data = ReadSARAS( [Group 'p'], Subj, Trial );
            Data = LowPassFilterSARAS(Data);
            Data = TangentialVelocity(Data);
            for GestNb = 1 : Data.NbPointing
                P = GetPointing(GestNb, Data);
                P = GetVelocityPeaks(P);
                [Results, Header] = ToStatFile( P, {'NbVelPeaks', 'MovementTime'} );
                Txt2File = [Txt2File, Results] ;
            end
        end
    end
end

Txt2File = [Header, Txt2File];          % add header to the numbers 
Save2Results('Results.txt', Txt2File);