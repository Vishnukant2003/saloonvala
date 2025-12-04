package com.salonvala.salonmanagement.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="queue_state")
public class QueueState {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer currentServingNumber;

    private Integer totalWaiting;

    @OneToOne
    @JoinColumn(name = "salon_id")
    private Salon salon;
}
