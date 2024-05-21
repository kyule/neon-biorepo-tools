data<-read.csv("/Users/kelsey/Downloads/invertSampNos.csv")

data$year<-as.numeric(paste0(20,sapply(strsplit(data$date,"/"),'[',3)))

data$yearfrac<-as.numeric(sapply(strsplit(data$date,"/"),'[',1))/12                       
data$shipDate<-data$year+data$yearfrac
                         
a<-data.frame(data %>% 
                group_by(shipDate) %>% 
                summarise(samples=sum(count)))

plot(samples~shipDate,a)
smoothingSpline = smooth.spline(a$shipDate, a$samples, spar=0.35)
lines(smoothingSpline,lwd=2,col="red")


b<-a[which(a$shipDate>=2021),]

plot(samples~shipDate,b)
smoothingSpline = smooth.spline(b$shipDate, b$samples, spar=0.35)
lines(smoothingSpline,lwd=2,col="red")
