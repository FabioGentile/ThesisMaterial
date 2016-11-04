#!/usr/bin/Rscript

library(powtran)

################################## 
myplot <- function(x, work.unit = NULL, highlight = NULL, main = NULL, ...) {
    P <- NULL  ## to mute down NOTE from R CMD check
    start <- end <- NULL  # to mute down CMD check
    
    # layout(matrix(c(1,1,1,1, 2,4,4,5, 2,4,4,5, 6,3,3,6),4,byrow=TRUE))
    layout(matrix(c(1, 1, 2, 4, 5, 3), 3, byrow = TRUE))
    push.mar = par("mar")
    par(mar = c(3, 2, 0.2, 0.2))
    
    if (is.null(work.unit)) {
        l = 1
        r = x$n
    } else {
        l = x$markers$start[min(work.unit)] - median(x$markers$length)
        r = x$markers$start[max(work.unit) + 1] + median(x$markers$length)
    }
    
    if (!"P" %in% names(x)) {
        if (is.null(work.unit)) {
            dsd = x$P.sample
        } else {
            wu = c(min(work.unit), 1 + max(work.unit))
            indexes = which(x$P.sample$t %in% x$t * x$work[wu, ]$start)
            dsd = x$P.sample[min(indexes):max(indexes), ]
        }
    } else {
        n = r - l
        m = mean(x$P[l:r])
        dsd = .ds(x$P[l:r], x$t)
        dsd$t <- dsd$t + (l - 1) * x$t
    }
    # plot(dsd$t,dsd$P,t='l',col='purple',...)
    plot(0, type = "n", axes = FALSE, ann = FALSE)
    
    with(subset(x$work, !is.na(P) & start > l & end < r), {
        rect(start * x$t, min(dsd$P), end * x$t, max(dsd$P), col = rgb(1, 0.64, 0, 
            0.2), border = "darkorange", lty = 3)
        text((start + end)/2 * x$t, min(dsd$P), which(!is.na(x$work$P)), col = "darkorange", 
            xpd = T, cex = 0.6)
    })
    if (any(is.na(x$work$P))) {
        with(subset(x$work, is.na(P)), {
            rect(start * x$t, min(dsd$P), end * x$t, max(dsd$P), col = rgb(0.6, 0.6, 
                0.6, 0.2), border = "lightgray", lty = 3)
            text((start + end)/2 * x$t, min(dsd$P), which(is.na(x$work$P)), col = "gray", 
                xpd = T, cex = 0.6)
        })
    }
    if ("markers" %in% names(x)) {
        rect(x$markers$start * x$t, min(dsd$P), x$markers$end * x$t, max(dsd$P), 
            col = rgb(0, 1, 0.6, 0.1), border = NA, lty = 2)
        text((x$markers$start + x$markers$end)/2 * x$t, max(dsd$P), col = "navy", 
            xpd = T, cex = 0.6)
    }
    
    bp <- function(x, ylab, col.point = 1, hollow = NULL, ...) {
        par = list(...)
        horizontal = FALSE
        if (!is.null(par$horizontal)) {
            horizontal = par$horizontal
        }
        
        MINX = 0
        if (horizontal) {
            boxplot(x, xlab = "", xlim = c(MINX, 1.2), ...)
            title(xlab = ylab, line = 2.25)
        } else {
            boxplot(x, ylab = "", xlim = c(MINX, 1.2), ...)
            title(ylab = ylab, line = 2.25)
        }
        xo = order(x)
        x <- x[xo]
        if (!is.null(hollow)) {
            hollow = hollow[xo]
        }
        cs = 0.02
        while (TRUE) {
            slots = floor((0.75 - MINX)/(2 * cs))
            l = min(x, na.rm = T)
            h = max(x, na.rm = T)
            int = findInterval(x, l + (0:slots) * (h - l)/slots)
            if (max(table(int)) < slots) 
                break
            cs = cs/5 * 4
        }
        pos = as.numeric(unlist(sapply(table(int, useNA = "ifany"), function(x) sample(seq(x), 
            x)))) - 1
        y = pos * cs * 2 + MINX
        
        if (horizontal) {
            asp.ratio = par("pin")[2]/par("pin")[1]
            xscale = diff(par("usr"))[1]
            
            cs <- cs * asp.ratio * xscale
            tmp = x
            x = y
            y = tmp
        }
        if (is.null(hollow)) 
            hollow <- rep(FALSE, length(x))
        
        if (!all(hollow)) 
            symbols(y[!hollow], x[!hollow], circles = rep(cs, length(x))[!hollow], 
                inches = FALSE, fg = NA, bg = col.point, add = TRUE)
        if (any(hollow)) {
            symbols(y[hollow], x[hollow], circles = rep(cs, length(x))[hollow], inches = FALSE, 
                fg = col.point, bg = NA, add = TRUE)
        }
        
        # segments(0,x,0.6,x,lwd=2,col=rgb(160/255,32/255,240/255,128/255))
    }
    
    
    par(mar = c(3, 4, 0, 2))
    bp(x$work$P, "Power [W]", "purple")
    
    par(mar = c(4, 3, 0, 3))
    bp(x$work$duration, "Duration [s]", "purple", horizontal = TRUE, hollow = is.na(x$work$P))
    
    par(mar = c(3, 3, 0, 3))
    plot(x$work$duration, x$work$P, xlab = "Duration [s]")
    x.to = par("usr")[2]
    y.from = par("usr")[3]
    even = TRUE
    energy = pretty(x$work$E)
    if (0 %in% energy) {
        zi = which(energy == 0)
        energy[zi] = min(energy[-zi])/5
    }
    for (e in energy) {
        if (even) {
            line.col = rgb(1, 0.549, 0, 0.6)
            text.col = rgb(1, 0.549, 0, 1)
        } else {
            line.col = rgb(0.627, 0.125, 0.941, 0.6)
            text.col = rgb(0.627, 0.125, 0.941, 1)
        }
        
        curve(e/x, from = max(par("usr")[1], 0), to = x.to, col = line.col, add = TRUE)
        y = e/x.to
        
        if (y > y.from) {
            text(x.to, y, format(e, digits = 2), xpd = TRUE, cex = 0.7, col = text.col, 
                adj = -0.1)
        } else {
            x0 = e/y.from
            text(x0, y.from, format(e, digits = 2), xpd = TRUE, cex = 0.7, col = text.col, 
                adj = c(0, -0.1))
        }
        even <- !even
    }
    
    par(mar = c(4, 4, 0, 2))
    bp(x$work$E, "Energy [J]", "orange")
    
    if (!is.null(main)) {
        x0 = par("usr")[1] - par("plt")[1]/(diff(par("plt"))[1]) * 0.75 * diff(par("usr"))[1]
        mtext(main, side = 1, at = x0, line = 2, adj = c(0, 0), xpd = TRUE, font = 2)
    }
    layout(1)
    par(mar = push.mar)
}
################################## 

read.from.zip <- function(zipfilename, skip = 1, n = NA) {
    if (!file.exists(zipfilename)) {
        stop("File ", zipfilename, "does not exists!")
    }
    files = subset(unzip(zipfilename, list = TRUE), Length > 0)
    
    if (dim(files)[1] == 1) {
        n = 1
    }
    if (is.na(n)) {
        stop("Must select a file index inside the zip.\n", "Available files:\n", 
            paste(seq(dim(files)[1]), ":", files$Name, collapse = "\n"))
    }
    filename = files$Name[n]
    conn = unz(zipfilename, filename)
    
    samples <- read.table(conn, dec = ",", header = TRUE, col.names = "P", skip = 7)
    # close(conn)
    return(samples)
}

########## FIXTURES ############
period = 1/1000
################################ 

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
    stop("Missing dirname.", call. = FALSE)
}

dirname = args[1]

filename_plain = paste(dirname, "Power.txt", sep = "/")
filename_zip = paste(dirname, "Power.zip", sep = "/")
outfile = paste(dirname, "daq.pdf", sep = "/")

################################## 

if (file.exists(filename_zip)) {
    print("ZIP")
    samples = read.from.zip(filename_zip)
} else {
    if (file.exists(filename_plain)) {
        print("PLAIN")
        samples = read.table(filename_plain, dec = ",", header = TRUE, col.names = "P", 
            skip = 7)
    } else {
        print("ERROR FILE NOT FOUND")
        print
        q()
    }
}
res = extract.power(samples, period, marker.length = 8)

summary(res)

pdf(file = outfile)
myplot(res)
dev.off()

# samples = read.from.zip(filename_zip) samples = read.table(filename, dec='.',
# header=TRUE, col.names='P', skip=0) samples/1000

# res = extract.power(samples/1000, period, marker.length=7,
# include.rawdata=TRUE) #res plot(res) summary(res)