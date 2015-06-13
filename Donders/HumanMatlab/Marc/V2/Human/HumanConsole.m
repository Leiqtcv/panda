% simple console
figure('name','console','numbertitle','off','menubar','none','Tag','Console');
hold on
xlim([-1 2])
ylim([-1 3])
axis ij
axis off
Hcons(1)=text(0,0,'Console line 1','verticalalign','middle','horizontalalign','center','fontname','fixedwidth');
Hcons(2)=text(1,0,'Console line 2','verticalalign','middle','horizontalalign','center','fontname','fixedwidth');
Hcons(3)=text(1,1,'Console line 3','verticalalign','middle','horizontalalign','center','fontname','fixedwidth');
Hcons(4)=text(1,2,'Console line 4','verticalalign','middle','horizontalalign','center','fontname','fixedwidth');
Hcons(5)=text(1,3,'Console line 5','verticalalign','middle','horizontalalign','center','fontname','fixedwidth','BackgroundColor','g');
