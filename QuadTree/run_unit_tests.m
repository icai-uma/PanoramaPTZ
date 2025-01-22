function status = run_unit_tests()
%run_unit_tests
%
%   Run these unit tests.

% Copyright (c) 01-14-2014,  Shawn W. Walker

Test_Files(1).FH = @test_Quadtree_Random_Points;
Test_Files(2).FH = @test_Quadtree_Moving_Points;

for ind = 1:length(Test_Files)
    status = Test_Files(ind).FH();
    if (status~=0)
        disp('Test failed!');
        disp(['See ----> ', func2str(Test_Files(ind).FH)]);
        break;
    end
end

if (status==0)
    disp('***QuadTree tests passed!');
end

end