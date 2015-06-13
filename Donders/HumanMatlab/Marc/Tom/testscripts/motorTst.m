%===========================================================================================
% Testen boog
%===========================================================================================
motor_globals;

disp('Init');
boog = AerMotor();
[boog msg] = Aer_cmd(boog, AerInit, 150000);

disp('Home');
[boog msg] = Aer_cmd(boog, AerMoveHome);
busy = 1;
while (busy == 1)
    [boog msg] = Aer_cmd(boog, AerMoveTestDone);
    disp(get(boog,'position'));
    busy = get(boog,'busy');
end
%%
disp('Init');
boog = AerMotor();
[boog msg] = Aer_cmd(boog, AerInit, 150000);

disp('move-> 55');
[boog msg] = Aer_cmd(boog, AerMoveAbs,55);
busy = 1;
while (busy == 1)
    [boog msg] = Aer_cmd(boog, AerMoveTestDone);
    disp(get(boog,'position'));
    busy = get(boog,'busy');
end
boog
%%
for i=1:10
    n = rand_num([0 600]);
    disp(sprintf('move(%d)-> %d\n',i,n));
    [boog msg] = Aer_cmd(boog, AerMoveAbs,n);
    busy = 1;
    while (busy == 1)
        [boog msg] = Aer_cmd(boog, AerMoveTestDone);
        busy = get(boog,'busy');
    end
end

[boog msg] = Aer_cmd(boog, AerMoveAbs,5);
busy = 1;
while (busy == 1)
    [boog msg] = Aer_cmd(boog, AerMoveTestDone);
    busy = get(boog,'busy');
end

%%
figure;
subplot(221);hold on
subplot(223);hold on
subplot(222);hold on
speed = linspace(100000,200000,10);
for i = speed
    disp('Init');
    boog = AerMotor();
    [boog msg] = Aer_cmd(boog, AerInit, i);
    [boog msg] = Aer_cmd(boog, AerMoveAbs,360);
    tic;
    busy = 1;
    vt = [];
    vp = [];
    while (busy == 1)
        [boog msg] = Aer_cmd(boog, AerMoveTestDone);
        t=toc;
        pos = get(boog,'position');
        %fprintf('pos: %5.2f t: %5.3f\n',pos,t);
        busy = get(boog,'busy');
        vt = [vt;t];
        vp = [vp;pos];
    end
    t=toc;
    pos = get(boog,'position');
    fprintf('pos: %5.2f t: %5.3f\n',pos,t);
    subplot(221)
    plot(i,t,'.');
    subplot(223)
    plot(vt,vp,'-');
    vel = diff(vp)./diff(vt);
    subplot(222)
    plot(vt(1:end-1),vel,'.')
    drawnow
end