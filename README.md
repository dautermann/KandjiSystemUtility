# Kandji System Utility Demo

## The ask:
> Your Task: Create a simple macOS System Utility Application that displays, at minimum:
> - Current CPU usage:
>   - Utilize low-level Darwin API code for precise CPU activity calculations.
>  - Ensure real-time updates in the UI.
> - Memory:
>   - Display total available and used memory.
>   - Disk space availability:
>   - Present a basic graph illustrating available space for all connected volumes (exclude system volumes).
> - User Interface:
>   - Maintain a clean, organized, and modern aesthetic, avoiding reliance solely on text elements.
> Guidelines:
> - You may use only native libraries / frameworks included in macOS — no command line tools, open source, or other ready-made solutions.
> - Swift should be the primary language.
> - Please spend no more than 3-4 hours on this assignment.

## Talking about the result:

This app is a typical MVC app (Model = datasource; View = displaying the data from the model; Controller = one view controller with the three views). I'm also very accustomed to doing other architectures such as MVVM, MVVP, etc. 

Three to four hours of work here and lots of places to do polishing, I wish I had the extra time to make things even more Swifty!

But I had enough fun just porting some Objective-C low level system code over to Swift.

## Things I'd love to do:

1) make the three segments totally resizeable (the first and second sections are fixed heights)

2) put something useful in the headerview of the cpu usage, or switch the progress indicators to level indicators with colors, like as in the disk usage view.

