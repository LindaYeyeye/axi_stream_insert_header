#### 关键场景
对于这个接口而言共有三种情况：

1、header data同时到 -->直接拼接进入移位寄存器

2、header 先到 data 后到  -->hdr在缓存中，等待data到来以后共同进入寄存器寄存

3、data先到，header后到 -->为了避免多级缓存，这里要确保header先于data到。
或者header同时到，用于控制data的ready信号，这里采用通过hdr的buffer空满来决定
是否接受data。

#### hdr_ready产生逻辑：
为了避免在同一次data发送过来时，有多个hdr送入，所以hdr的接受由buffer的状态决定，
hdr只要接受过，同时没有被发送走，变不重新接受，因为接受了也发不出去。

#### data_ready产生逻辑：
为了避免超大缓存的出现（data不停握手送入，hdr迟迟未到，导致前级data被缓存）这里data
仅在hdr buffer已满后才接受数据流。

#### 测试用例：
1、hdr data同时发送
	hdr，data直接送入shiftreg中，依次移位输出，取高位，等待last发送后清空buffer

2、hdr先于data发送
	hdr_buffer将存储在一次发送后首先接受的hdr，并存入buffer，终止hdr的接受，等待新一波data的到来。

3、data先于hdr发送
	data等待hdr发送后才开始ready接受

4、由于没有使用fifo缓存，所以无法对断续发送的data进行处理。换句话说，当data的valid是脉冲进入时，
该模块无法处理。
